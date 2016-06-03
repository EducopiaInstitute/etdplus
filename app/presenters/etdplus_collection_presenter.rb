class EtdplusCollectionPresenter < Sufia::CollectionPresenter
  self.terms = [:resource_type, :title, :creator, :contributor, :description,
                :tag, :rights, :publisher, :date_created, :subject, :language,
                :identifier, :based_near, :related_url, :proquest_inputs]
end
