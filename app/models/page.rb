class Page < ActiveFedora::Base
  contains "pageContent"
  contains "full_text"
  belongs_to :generic_file, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf
  
  property :number, predicate: ::RDF::URI.new('http://opaquenamespace.org/hydra/pageNumber'), multiple: false do |index|
    index.as :stored_searchable
    index.type :integer
  end
  
  def associate(gf)
  	 self.generic_file_id = gf.id
  	 gf.pages << self
  	 #gf.page_ids << self.id
  	 self.save
  	 date = DateTime.now.strftime("%Y%m%d-%H%M%S%L")
  	 resp = ActiveFedora.fedora.connection.post(self.full_text.uri.value+"/fcr:versions", nil, {slug: date+"-SystemCRON-"+rand(0..9999999).to_s})
     resp.success?
 end
  
  class << self
	  
  	  def makePage(file, i, textPage, logger)
  	  	  index = i+1
		  jpg = file.id+index.to_s+".jpg"
		  txtpg = file.id+index.to_s+".txt"
		  filename = file.id+File.extname(file.filename.first)
		  data = ActiveFedora.fedora.connection.get(file.content.uri.value).body
		  File.open("/tmp/"+filename, "wb") {|f| f.write(data)}
		  logger.info "Page: "+index.to_s
		  ext = File.extname(file.filename.first)
		  logger.info "starting conversion"
		  logger.debug "convert -density 300 /tmp/"+file.id+ext+ (ext==".pdf" ? "["+i.to_s+"] /tmp/" : " /tmp/")+jpg
		  system("convert -density 300 /tmp/"+file.id+ext+ (ext==".pdf" ? "["+i.to_s+"] /tmp/" : " /tmp/")+jpg)
		  logger.info "Conversion Complete"
		  if (textPage==nil)
			  logger.info "starting Tesseract"
			  system("tesseract /tmp/"+jpg+" /tmp/"+file.id+index.to_s)
			  logger.info "Tesseract Complete"
		  else
		  	  logger.info "writing: /tmp/"+txtpg
		  	  File.open("/tmp/"+txtpg, "w+") { |f| f.write(textPage) }
		  end
		  page = Page.new(file.id + index.to_s)
		  page.number = index
		  logger.info "loading text file"
		  page.full_text.content = File.open("/tmp/"+txtpg) 
		  logger.info "loading content file"
		  page.pageContent.content = File.open("/tmp/"+jpg)
		  page.pageContent.mime_type = "image/jpeg"
		  page.pageContent.original_name = jpg
		  logger.info "associating file"
		  page.associate(file)
		  File.delete("/tmp/"+filename)
		  File.delete("/tmp/"+jpg)
		  File.delete("/tmp/"+txtpg)
  	  end
  	  
  	  def makePages(file, logger)
  	  	  if (file.pages.count == 0)
			  filename = file.id+File.extname(file.filename.first)
			  logger.info "found: "+filename
			  txt = file.id+".txt"
			  data = ActiveFedora.fedora.connection.get(file.content.uri.value).body
			  File.open("/tmp/"+filename, "wb") {|f| f.write(data)}
			  logger.info "curled: "+filename
			  sysCommand = 'pdftotext /tmp/' +filename+' /tmp/'+ txt
			  txtExists = system(sysCommand)
			  if((txtExists) && (tempFile = File.open("/tmp/"+txt, "r").size > 2000))
				  logger.info "scraped: "+sysCommand
				  tempFile = File.open("/tmp/"+txt, "r")
				  text = tempFile.read
				  tempFile.close
				  logger.info "read file"
				  textPages = text.split("\f")
				  logger.info "split "+textPages.count.to_s+" pages"
				  i = 0
				  textPages.each do |textPage| 
					  makePage(file, i, textPage, logger)
					  i += 1
				  end
				  File.delete("/tmp/"+file.id+".txt")
			  else
				  logger.info "scrape failed; begining manual OCR"
				  if(File.extname(file.filename.first)==".pdf")
					  pageCount = file.page_count.map(&:to_i)
					  for i in 0..(pageCount.max-1)
						  makePage(file, i, nil, logger)
					  end
				  else
				  	  makePage(file, 0, nil, logger)
				  end
			  end
		  end
  	  end
  	  
	  def newPageCron(id)
	  	  logger = Logger.new("/tmp/Cron.log")
		  logger.info "starting ocr cron"
		  if(id == nil)
			  files = GenericFile.where(OCR: "1")
			  logger.info "got ocr files"
			  files.each do |file|
				  logger.info "File id: "+file.id
				  if (file.mime_type == "application/pdf")
				  	  makePages(file, logger)
				  else
					  makePage(file, 0, nil, logger)
				  end
				  file.OCR = ""
				  file.save
			  end
		  else
		  	  file = GenericFile.find(id)
		  	  logger.info "File id: "+file.id
			  if (file.mime_type == "application/pdf")
				  makePages(file, logger)
			  else
				  makePage(file, 0, nil, logger)
			  end
		  end
	  rescue => ex
	  	  logger.error ex.to_s
	  end
  end
end