class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  before_save :bulk_extractor_inspect

  property :pii_inspect_event, predicate: ::RDF::DC.provenance

  private	
        def bulk_extractor_inspect
          filename = Rails.root.join("tmp", "#{self.id}_text_content.txt")
          text_file = File.new(filename, 'w')
          text_file.write append_metadata.gsub("\n", " ")
          text_file.close
          filename = text_file.path
          cmd_string = "bulk_extractor -o tmp/bulk_extractor_output #{filename}"
          Open3.popen3(cmd_string)
          sleep(1)
          found_pii = []
          Dir.chdir("tmp/bulk_extractor_output") do
            found_pii = Dir.foreach('.').select { |entry|
              (entry == "ccn.txt" || entry == "pii.txt") && File.size(entry) > 0
            }
          end
          FileUtils.rm_rf("tmp/bulk_extractor_output") # output dir must not exist
          File.delete(filename)
          depositor = User.find_by_user_key(self.depositor)
          gf_actor = Sufia::GenericFile::Actor.new(self, depositor)
          if found_pii.empty?
            gf_actor.update_metadata({pii_inspect_event: ['No pii detected']}, visibility)
            return true
          elsif found_pii.length == 2
            message = 'Found SSN and Credit Card Number'
          else
            message = (found_pii[0] == "pii.txt" ? "Found SSN" : "Found Credit Card Number")
          end
          logger.warn(message)
          errors.add(:base, message)
          PiiMailer.destroy_file(id).deliver_later
          gf_actor.destroy
          return false
        end

end
