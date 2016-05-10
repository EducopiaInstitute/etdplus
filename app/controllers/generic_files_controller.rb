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

  protected

    def process_file(file)
      super
      error_msg = @generic_file.errors.full_messages.join(', ')
      if error_msg.include? "PII found"
        PiiMailer.destroy_file(@generic_file.depositor, file.original_filename).deliver_later
      elsif error_msg.include? "A virus was found"
        VirusScanMailer.destroy_file(@generic_file.depositor, file.original_filename).deliver_later
      end
    end
end
