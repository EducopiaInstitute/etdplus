# -*- coding: utf-8 -*-
class GenericFilesController < ApplicationController
  include Sufia::Controller
  include Sufia::FilesControllerBehavior

  def show
    super
    xml_doc = GenericFile.find(params[:id]).characterization.ng_xml
    # fits as the root node contains multiple section child elements
    @section_elements = xml_doc.element_children[0].element_children
  end 
end
