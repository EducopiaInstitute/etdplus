module Etdplus
  module CollectionBehavior
    extend ActiveSupport::Concern
    extend Deprecation
    include Hydra::WithDepositor # for access to apply_depositor_metadata
    include Hydra::AccessControls::Permissions
    include Hydra::Collections::Collectible
    include Etdplus::Collections::Metadata
    include Hydra::Collections::Relations
    include Sufia::ModelMethods
    include Sufia::Noid
    include Sufia::GenericFile::Permissions

    included do
      before_save :update_permissions
      validates :title, presence: true
      validates :rights, presence: true
    end

    def update_all_members
      Deprecation.warn(Collection, 'update_all_members is deprecated and will be removed in version 5.0')
      self.members.collect { |m| update_member(m) }
    end

    # TODO: Use solr atomic updates to accelerate this process
    def update_member member
      Deprecation.warn(Collection, 'update_member is deprecated and will be removed in version 5.0')
      # because the member may have its collections cached, reload that cache so that it indexes the correct fields.
      member.collections(true) if member.respond_to? :collections
      member.update_index
    end

    def add_members new_member_ids
      return if new_member_ids.nil? || new_member_ids.size < 1
      self.members << ActiveFedora::Base.find(new_member_ids)
    end

    def update_permissions
      self.visibility = "open"
    end

    # Compute the sum of each file in the collection using Solr to
    # avoid having to hit Fedora
    #
    # @return [Fixnum] size of collection in bytes
    # @raise [RuntimeError] unsaved record does not exist in solr
    def bytes
      rows = members.count
      return 0 if rows == 0

      raise "Collection must be saved to query for bytes" if new_record?

      query = ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: file_model)
      args = {
        fq: "{!join from=hasCollectionMember_ssim to=id}id:#{id}",
        fl: "id, #{file_size_field}",
        rows: rows
      }

      files = ActiveFedora::SolrService.query(query, args)
      files.reduce(0) { |sum, f| sum + f[file_size_field].to_i }
    end

    protected

      # Field to look up when locating the size of each file in Solr.
      # Override for your own installation if using something different
      def file_size_field
        Solrizer.solr_name('file_size', stored_integer_descriptor)
      end

      # Override if you are storing your file size in a different way
      def stored_integer_descriptor
        Sufia::GenericFileIndexingService::STORED_INTEGER
      end

      # Override if not using GenericFiles
      def file_model
        ::GenericFile.to_class_uri
      end
  end
end
