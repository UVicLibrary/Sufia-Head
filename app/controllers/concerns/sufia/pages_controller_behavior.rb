module Sufia
	module PagesControllerBehavior
		
		def update
			@page = Page.find(params[:id])
			@page.full_text.content = params[:OCR_Text]
			@page.save
			fedora_url = @page.full_text.uri.value+"/fcr:versions"
			slug = DateTime.now.strftime("%Y%m%d-%H%M%S.%L")+"-"+current_user.name+"-"+rand(0..9999999).to_s
			resp = ActiveFedora.fedora.connection.post(fedora_url, nil, {slug: slug})
			if resp.success?
				redirect_to show_page_path(@page)
			end
		end
	end
end