class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  before_save :sanitize_filenames

  property :virus_scan_event, predicate: ::RDF::DC.provenance

  private

    def sanitize_filenames
      filename_options = Rails.configuration.x.filename_options
      filename_options[:allow_unicode] ||= false
      filenames = []

      self.filename.each do |filename|
        filename = I18n.transliterate(filename) if not filename_options[:allow_unicode]
        filename = Zaru.sanitize!(filename, filename_options)
        filenames << filename
      end

      self.filename = filenames
    end
end
