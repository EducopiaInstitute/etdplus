class VirusScanJob < ActiveFedoraIdBasedJob
  def queue_name
    :virus_scan
  end

  def run
    depositor = User.find_by_user_key(generic_file.depositor)
    gf_actor = Sufia::GenericFile::Actor.new(generic_file, depositor)
    Sufia::GenericFile::Actor.virus_check(local_path_for_content)
    gf_actor.update_metadata({virus_scan_event: ['No viruses detected']}, generic_file.visibility)
  rescue Sufia::VirusFoundError => virus
    generic_file.logger.warn(virus.message)
    generic_file.errors.add(:base, virus.message)
    if Rails.configuration.x.destroy_viruses_immediately
      VirusScanMailer.destroy_file(generic_file.id).deliver_later
      gf_actor.destroy
    else
      gf_actor.update_metadata({virus_scan_event: ['Virus detected, file embargoed'], read_groups: ['private']}, 'restricted')
      VirusScanMailer.embargo_file(generic_file.id).deliver_later
    end
  end

  private

    def local_path_for_content
      if generic_file.content.respond_to?(:path)
        local_path_for_content = content.path
      else
        Tempfile.open('') do |t|
          t.binmode
          t.write(generic_file.content.content)
          t.close
          local_path_for_content = t.path
        end
      end
    end
end
