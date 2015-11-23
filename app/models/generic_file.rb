class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  before_save :sanitize_filenames
  before_save :bulk_extractor_inspect

  property :virus_scan_event, predicate: ::RDF::DC.provenance
  property :pii_inspect_event, predicate: ::RDF::DC.provenance

  def bulk_extractor_inspect
    found_pii = []
    Dir.mktmpdir do |dir|
      file = Tempfile.new(['', '.txt'])
      file.write g.append_metadata.gsub /\s+/, ' '
      file.close
      cmd_string = "bulk_extractor -o #{dir}/bulk_extractor #{file.path}"
      Open3.popen3(cmd_string)
      sleep(1)
      found_pii = Dir.foreach("#{dir}/bulk_extractor").select { |entry|
        (entry == "ccn.txt" || entry == "pii.txt") && File.size("#{dir}/bulk_extractor/#{entry}") > 0
      }
    end
    depositor = User.find_by_user_key(self.depositor)
    gf_actor = Sufia::GenericFile::Actor.new(self, depositor)
    if found_pii.empty?
      gf_actor.update_metadata({pii_inspect_event: ['No pii detected']}, visibility)
      return
    elsif found_pii.length == 2
      message = 'Found SSN and Credit Card Number'
    else
      message = (found_pii[0] == "pii.txt" ? "Found SSN" : "Found Credit Card Number")
    end
    logger.warn(message)
    errors.add(:base, message)
    PiiMailer.destroy_file(id).deliver_later
    gf_actor.destroy
  end

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
