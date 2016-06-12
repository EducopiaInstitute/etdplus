module EtdplusHelper

  def fits_tools_to_display(parent_element)
    blacklist = Rails.configuration.x.fits_display_blacklist
    if parent_element
      if parent_element.name == 'identity'
        attr_array = fits_identity_attributes(parent_element).map {|a| a.name }
        parent_element.element_children.reject { |tool| 
          blacklist.keys.include?(tool["toolname"].to_sym) && blacklist[tool["toolname"].to_sym].any? { |t| (['*', tool.name] + attr_array).include? t}
        }
      else
        parent_element.element_children.reject { |tool| 
          blacklist.keys.include?(tool["toolname"].to_sym) && blacklist[tool["toolname"].to_sym].any? { |t| ['*', tool.name].include? t}
        }
      end
    else
      []
    end
  end

  def fits_identity_attributes(identity_element)
    identity_element.attribute_nodes.reject { |a| ["toolname", "toolversion"].include?(a.name) }
  end
 
  def export_proquest_button(collection)
    if collection.has_one_main_etd?
      title = "Export this Collection as a ProQuest package"
      disabled = false
      name = "ProQuest Export"
    else
      title = "Should have exactly one ProQuest Main ETD PDF file"
      disabled = true
      name = '<span class="disabled btn btn-disabled">ProQuest Export</span>'.html_safe
    end
    link_to name, export_proquest_collection_path, title: title, disabled: disabled
  end 

  def proquest_submission(collection)
    if inputs = collection.proquest_inputs
     JSON.parse(inputs)["DISS_submission"]
    end
  end

  def author_name(submission)
    submission.nil? ? {} : submission["DISS_authorship"]["DISS_author"]["DISS_name"]
  end

  def author_contact(submission)
    submission.nil? ? {} : submission["DISS_authorship"]["DISS_author"]["DISS_contact"]
  end

  def author_phone_fax(contact)
    contact.empty? ? {} : contact["DISS_phone_fax"]
  end

  def author_address(contact)
    contact.empty? ? {} : contact["DISS_address"]
  end

  def proquest_description(submission)
    submission.nil? ? {} : submission["DISS_description"]
  end

  def dates(description)
    description.empty? ? {} : description["DISS_dates"]
  end

  def institution(description)
    description.empty? ? {} : description["DISS_institution"]
  end

  def advisor_name(description)
    description.empty? ? {} : description["DISS_advisor"]["DISS_name"]
  end

  def cmte_members(description)
    description.empty? ? [] : description["DISS_cmte_member"]
  end

  def cmte_member_name(cmte_member)
    cmte_member.nil? ? {} : cmte_member["DISS_name"]
  end

  def categorization(description)
    description.empty? ? {} : description["DISS_categorization"]
  end

  def categories(categorization)
    categorization.empty? ? [] : categorization["DISS_categories"]
  end

  def category(category)
    category.empty? ? {} : category["DISS_category"]
  end

  def proquest_content(submission)
    submission.nil? ? {} : submission["DISS_content"]
  end
end

