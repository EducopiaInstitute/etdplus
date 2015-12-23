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
        #depositor = User.find_by_user_key(self.depositor)
        #gf_actor = Sufia::GenericFile::Actor.new(self, depositor)
        Sufia::GenericFile::Actor.virus_check(local_path_for_content)
        #gf_actor.update_metadata({virus_scan_event: ['No viruses detected']}, visibility)
        true
      rescue Sufia::VirusFoundError => virus
        logger.warn(virus.message)
        errors.add(:base, virus.message)
        if Rails.configuration.x.destroy_viruses_immediately
          VirusScanMailer.destroy_file(generic_file.id).deliver_later
          false
        else
          #gf_actor.update_metadata({virus_scan_event: ['Virus detected, file embargoed'], read_groups: ['private']}, 'restricted')
          VirusScanMailer.embargo_file(generic_file.id).deliver_later
          true
        end
      end

      private

        def local_path_for_content
          if content.content.respond_to?(:path)
            content.content.path
          else
            Tempfile.open('') do |t|
              t.binmode
              t.write(content.content)
              t.close
              t.path
            end
          end
        end
    end
  end
end

