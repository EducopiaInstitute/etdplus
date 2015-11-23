require 'fileutils'

class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Etdplus::GenericFile::PiiDetect

  contains 'piiMetadata', class_name: 'PiiDatastream'

  property :ssn, delegate_to: 'piiMetadata' do |index|
    index.as :stored_searchable
  end
  property :ccn, delegate_to: 'piiMetadata' do |index|
    index.as :stored_searchable
  end

  property :virus_scan_result, predicate: ::RDF::DC.provenance do |index|
    index.as :stored_searchable, :facetable
  end

  property :pii_scan_result, predicate: ::RDF::DC.provenance do |index|
    index.as :stored_searchable, :facetable
  end

  def bulk_extractor_inspect
    #filename = File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'gf_text_content', "#{self.id}_text_content.txt")
    #text_file = File.new(filename, 'w')
    #self.characterize
    #text_file.write append_metadata.gsub("\n", "")
    #text_file.close
    config = YAML.load_file(Rails.root.join('config', 'fedora.yml'))[ENV["RAILS_ENV"]]
    uri = self.load_attached_files[0]
    text_file = open(uri, :http_basic_authentication => [config['user'], config['password']])
    filename = text_file.path
    #text_file.close
    Dir.chdir("/Users/virjtt03/bulk_extractor-1.5.5")
    cmd_string = "bulk_extractor -o output2 #{filename}"
    #puts cmd_string
    Open3.popen3(cmd_string)
    #File.open(text_file, 'r') do |file|
      #file.each_line {|line| puts line }
    #end
    sleep(1)
    Dir.chdir("./output2")
    found_pii = Dir.foreach('.').select { |entry|
      #if File.file?(entry) && File.readable?(entry) && (entry == "pii.txt" || entry == "ccn.txt")
      (entry == "ccn.txt" || entry == "pii.txt") && File.size(entry) > 0
    }
    if found_pii.empty?
      return false
    elsif found_pii.length == 2
      puts "Found SSN and Credit Card Number"
    else
      puts found_pii[0] == "pii.txt" ? "Found SSN" : "Found Credit Card Number"
    end
    FileUtils.rm_rf("../output2") # output dir must not exist
    File.delete(filename)
    return found_pii
  end

  def scan_virus

  end
end
