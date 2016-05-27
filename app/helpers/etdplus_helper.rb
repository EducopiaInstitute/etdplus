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

end

