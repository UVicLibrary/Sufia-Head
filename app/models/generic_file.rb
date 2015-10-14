class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

    property :abstract, predicate: ::RDF::DC.abstract do |index|
      index.as :stored_searchable, :facetable
    end

    property :education_level, predicate: ::RDF::DC.educationLevel do |index|
      index.as :stored_searchable, :facetable
    end

end