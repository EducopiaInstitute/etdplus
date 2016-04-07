module Etdplus 
  module SolrDocumentBehavior
    extend ActiveSupport::Concern
    include Sufia::SolrDocumentBehavior
    
    def rights
      Array(self[Solrizer.solr_name('rights')]).first
    end
  end
end
