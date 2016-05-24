require 'etdplus/models/pii_found_error'

class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Etdplus::GenericFile::VirusCheck

  before_save :sanitize_filenames
  validate :detect_pii
  property :scan_event, predicate: ::RDF::DC.provenance

  def ondemand_validate_xml
    return true unless self.mime_type == "text/xml"
    bad_doc = Nokogiri::XML(content.content)
    parsing_errors = bad_doc.errors
    unless parsing_errors.empty?
      logger.warn(parsing_errors * ", ")
      XmlMailer.warn_file(self.depositor, self.filename, parsing_errors * ", ").deliver_later
      self.scan_event = self.scan_event.to_a.push("Bad-formed XML detected on #{Time.now.strftime('%d/%m/%Y %H:%M')}")
      save
      false
    else
      self.scan_event = self.scan_event.to_a.push("Passed XML check on #{Time.now.strftime('%d/%m/%Y %H:%M')}")
      save
    end
  end

  def detect_pii
    return unless content.changed?
    begin
      bulk_extractor_scan
    rescue Etdplus::PiiFoundError => pii
      logger.warn(pii.message)
      if Rails.configuration.x.destroy_pii_immediately
        errors.add(:base, pii.message)
        false
      else
        self.scan_event = self.scan_event.to_a.push("Failed PII Check on #{Time.now.strftime('%d/%m/%Y %H:%M')}, file embargoed")
        self.read_groups = ['private']
        PiiMailer.embargo_file(self.depositor, self.content.original_name).deliver_later
        true
      end
    else
      self.scan_event = self.scan_event.to_a.push("Passed PII check on #{Time.now.strftime('%d/%m/%Y %H:%M')}")
      true
    end
  end

  def ondemand_detect_pii
    begin
      bulk_extractor_scan
    rescue Etdplus::PiiFoundError => pii
      logger.warn(pii.message)
      if Rails.configuration.x.destroy_pii_immediately
        Sufia::GenericFile::Actor.new(self, self.depositor).destroy
        PiiMailer.destroy_file(self.depositor, self.filename).deliver_later
        false
      else
        self.scan_event = self.scan_event.to_a.push("Failed PII Check on #{Time.now.strftime('%d/%m/%Y %H:%M')}, file embargoed")
        self.read_groups = ['private']
        PiiMailer.embargo_file(self.depositor, self.filename).deliver_later
        save
      end
    else
      self.scan_event = self.scan_event.to_a.push("Passed PII check on #{Time.now.strftime('%d/%m/%Y %H:%M')}")
      save
    end
  end

  def bulk_extractor_scan
    found_pii = []
    file_path = local_path_for_content
    Dir.mktmpdir do |dir|
      cmd_string = "bulk_extractor -o #{dir}/bulk_extractor #{file_path}"
      Open3.popen3(cmd_string)
      sleep(1)
      found_pii = Dir.foreach("#{dir}/bulk_extractor").select { |entry|
        (entry == "ccn.txt" || entry == "pii.txt") && File.size("#{dir}/bulk_extractor/#{entry}") > 0
      }
    end
    unless found_pii.empty?
      message = "PII found in #{file_path}: "
      if found_pii.length == 2
        message += "SSN and Credit Card Number"
      else
        message += (found_pii[0] == "pii.txt" ? "SSN" : "Credit Card Number")
      end
      message += ". File cannot be uploaded into the repository."
      raise Etdplus::PiiFoundError, message
    end
  end

  def main_etd_pdf?
    (resource_type.include? "ProQuest Main ETD PDF") && self.pdf?
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
