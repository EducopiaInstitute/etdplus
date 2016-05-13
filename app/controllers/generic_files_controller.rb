# -*- coding: utf-8 -*-
class GenericFilesController < ApplicationController
  include Sufia::Controller
  include Sufia::FilesControllerBehavior

  def show
    super
    xml_doc = GenericFile.find(params[:id]).characterization.ng_xml
    # fits as the root node contains multiple section child elements
    @section_elements = xml_doc.element_children[0].element_children

    @file_feedback = case
      when Rails.configuration.x.file_feedback_level1.include?(@generic_file.mime_type)
        ['green', 'Level One Support']
      when Rails.configuration.x.file_feedback_level2.include?(@generic_file.mime_type)
        ['blue', 'Level Two Support']
      when Rails.configuration.x.file_feedback_level3.include?(@generic_file.mime_type)
        ['yellow', 'Level Three Support']
      else
        ['red', 'Unknown Support Level']
    end
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
