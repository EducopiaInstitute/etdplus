class Collection < ActiveFedora::Base
  include Etdplus::CollectionBehavior

  before_save :clean_proquest_inputs

  def main_etds
    members.select { |m| m.resource_type.include? "ProQuest Main ETD PDF" }
  end

  # check if the collection has exactly one ProQuest main ETD with PDF format
  def has_one_main_etd?
    main_etds.size == 1
  end

  def main_etd_filename
    main_etds[0].filename[0] if has_one_main_etd?
  end

  def can_add_to_proquest_etd_collection?(gf)
    if proquest_etd_collection? && !has_one_main_etd?
      gf.main_etd_pdf?
    else
      true
    end
  end

  def proquest_etd_collection?
    self.resource_type.include? "ProQuest ETD"
  end

  private
    def clean_proquest_inputs
      self.proquest_inputs = nil unless self.resource_type.include?("ProQuest ETD")
    end
end
