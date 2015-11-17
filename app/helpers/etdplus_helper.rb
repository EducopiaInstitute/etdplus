module EtdplusHelper

  def fits_tools_to_display(parent_element)
    blacklist = Rails.configuration.x.fits_display_blacklist
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
  end

  def fits_identity_attributes(identity_element)
    identity_element.attribute_nodes.reject { |a| ["toolname", "toolversion"].include?(a.name) }
  end

end

