class Collection < Sufia::Collection
  validates :rights, presence: true

  property :rights, predicate: ::RDF::Vocab::DC.rights, multiple: false do |index|
    index.as :stored_searchable
  end
end
