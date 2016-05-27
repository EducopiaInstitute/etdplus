class Collection < ActiveFedora::Base
  include Etdplus::CollectionBehavior

  # check if the collection has exactly one ProQuest main ETD with PDF format
  def has_one_main_etd?
    etds = members.select { |m| m.resource_type.include? "ProQuest Main ETD PDF" }
    etds.size == 1
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

end
