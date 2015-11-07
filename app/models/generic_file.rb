class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

    has_many :pages
  
    property :abstract, predicate: ::RDF::DC.abstract do |index|
      index.as :stored_searchable, :facetable
    end

    property :education_level, predicate: ::RDF::DC.educationLevel do |index|
      index.as :stored_searchable, :facetable
    end

    property :OCR, predicate: ::RDF::Value, multiple: false do |index|
      index.as :stored_searchable, :facetable
    end
end