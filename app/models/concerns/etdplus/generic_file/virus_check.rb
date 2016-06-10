module Etdplus
  module GenericFile
    module VirusCheck
      extend ActiveSupport::Concern

      included do
        validate :detect_viruses
      end

      # Default behavior is to raise a validation error and halt the save if a virus is found
      def detect_viruses
        return unless content.changed?
        begin
          Sufia::GenericFile::Actor.virus_check(local_path_for_content)
        rescue Sufia::VirusFoundError => virus
          if Rails.configuration.x.destroy_viruses_immediately
            errors.add(:base, virus.message)
            false
          else
            self.scan_event = self.scan_event.to_a.push("Failed Virus Check on #{Time.now.strftime('%d/%m/%Y %H:%M')}, file embargoed")
            self.read_groups = ['private']
            VirusScanMailer.embargo_file(self.depositor, self.content.original_name).deliver_later
            true
          end
        else
          self.scan_event = self.scan_event.to_a.push("Passed Virus Check on #{Time.now.strftime('%d/%m/%Y %H:%M')}")
          true
        end
      end

      def ondemand_detect_viruses(system_scan = false)
        begin
          Sufia::GenericFile::Actor.virus_check(local_path_for_content)
        rescue Sufia::VirusFoundError => virus
          if Rails.configuration.x.destroy_viruses_immediately
            Sufia::GenericFile::Actor.new(self, User.find_by_user_key(self.depositor)).destroy
            VirusScanMailer.destroy_file(self.depositor, self.filename).deliver_later
            false
          else
            self.scan_event = self.scan_event.to_a.push("Failed Virus Check on #{Time.now.strftime('%d/%m/%Y %H:%M')}, file embargoed")
            self.read_groups = ['private']
            VirusScanMailer.embargo_file(self.depositor, self.filename).deliver_later
            save
            return false if system_scan
          end
        else
          self.scan_event = self.scan_event.to_a.push("Passed Virus Check on #{Time.now.strftime('%d/%m/%Y %H:%M')}")
          save
        end
      end
    end
  end
end

