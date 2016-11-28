require  'sufia/models/virus_found_error'

class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  skip_load_and_authorize_resource :only => [:export_bagit, :export_proquest, :bagit_download]

  def presenter_class
    EtdplusCollectionPresenter
  end

  def form_class
    EtdplusCollectionEditForm
  end

  def create_mets(collection, namespaces)
  
    b = Nokogiri::XML::Builder.new

    b[:mets].mets(namespaces) {
      b[:mets].metsHdr("CREATEDATE" => collection.date_created[0], "LASTMODDATE" => "2015-11-30T04:28:25")  {
        b[:mets].agent("ROLE" => "CREATOR", "TYPE" => "ORGANIZATION" ) {
          b[:mets].name('UNIVERSITY or SCHOOL')
        }
      }

      b[:mets].dmdSec("ID" => "DMR1") {
        b[:mets].mdRef("xlink:href" => "http://oskicat.berkeley.edu/search/v?SEARCH=GLADN184985770",
          "LOCTYPE" => "URL",
        "MDTYPE" => "MARC",
        "LABEL" => "Catalog Record") {}
      }

      b[:mets].dmdSec("ID" => "DMR1") {
        b[:mets].mdWrap("MDTYPE" => "MODS",
          "LABEL" => collection.title) {
          b[:mets].xmlData() {
            b[:mods].mods() {
              b[:mods].titleInfo() {
                b[:mods].title(collection.title)
              }

              # multiple AUTHOR
              b[:mods].name("type" => "personal") {
                b[:mods].namePart("ETD AUTHOR")
                b[:mods].role() {
                  b[:mods].roleTerm("type" => "text", "authority" => "marcrelator"){
                    b[:mods].text("Author")
                  }
                }
              }

              b[:mods].typeOfResource("text")
              b[:mods].genre("authority" => "aat"){
              b[:mods].text("THESES or DISSERTATIONS")
            }

            b[:mods].originInfo() {
              b[:mods].place() {
                b[:mods].placeTerm("type" => "text") {
                  b[:mods].text("DEGREE GRANTING INSTITUTION")
                }
              }
              b[:mods].publisher("DEGREE GRANTING DEPARTMENT")
              b[:mods].dateCreated("DEFENSE DATE")
            }

            b[:mods].language() {
              b[:mods].languageTerm("type" => "code", "authority" => "iso639-2b") {
                b[:mods].text("LANGUAGE")
              }
            }
            b[:mods].physicalDescription()
            }
          }
        }
      }

      b[:mets].amdSec() {
        b[:mets].rightsMD("ID" => "RMD1") {
          b[:mets].mdWrap("MDTYPE" => "OTHER", "OTHERMDTYPE" => "METSRights") {
            b[:mets].xmlData() {
              b[:rts].RightsDeclarationMD("RIGHTSCATEGORY" => "COPYRIGHTED") {
                b[:rts].RightsHolder() {
                  b[:rts].RightsHolderName("The author(s)")
                  b[:rts].RightsHolderContact("RIGHTS HOLDER CONTACT")
                  b[:rts].RightsHolderContactAddress("address")
                }
                b[:rts].Context("CONTEXTCLASS" => "GENERAL PUBLIC") {
                  b[:rts].Constraints() {
                    b[:rts].ConstraintDescription("RIGHTS STATEMENT")
                  }
                }
              }
            }
          }
        }
      }

      b[:mets].fileSec() {
      }

      b[:mets].structMap() {
        b[:mets].div("TYPE" => "text", "LABEL" => collection.title, "ADMID" => "RMD1", "DMDID" => "DMR1 DM1")
      }

    }

    return b.to_xml

  end

  def insert_event(metsxml, eventnum, checktype, checktime, message, status, tool, version)

    evendata = {}
    evendata["number"] = eventnum
    evendata["name"] = checktype
    evendata["time"] = checktime
    evendata["detail"] = message
    evendata["status"] = status
    evendata["tool"] = tool
    evendata["version"] = version
    metsxml = create_event_xml(metsxml, evendata)
    
    return metsxml

  end

  def create_event_xml(metsxml, eventdata)
    doc = Nokogiri::XML(metsxml)
    doc.xpath('//mets:mets').each do |node|

      b = Nokogiri::XML::Node.new "digiprovMD", doc
      b['ID'] = eventdata["number"] 
      mdWrap = Nokogiri::XML::Node.new "mdWrap", b
      mdWrap['MDTYPE'] = "PREMIS:EVENT"
      xmlData = Nokogiri::XML::Node.new "xmlData", mdWrap
      event = Nokogiri::XML::Node.new "premis:event", xmlData
      eventType = Nokogiri::XML::Node.new "eventType", event
      eventType.content = eventdata["name"]
      eventDateTime = Nokogiri::XML::Node.new "eventDateTime", event
      eventDateTime.content = eventdata["time"]
      eventDetail = Nokogiri::XML::Node.new "eventDetail", event
      eventDetail.content = eventdata["detail"]
      eventOutcomeInformation = Nokogiri::XML::Node.new "eventOutcomeInformation", event
      eventOutcome = Nokogiri::XML::Node.new "eventOutcome", eventOutcomeInformation
      eventOutcome.content = eventdata["status"]
      linkingAgentIdentifier = Nokogiri::XML::Node.new "linkingAgentIdentifier", event
      linkingAgentIdentifierType = Nokogiri::XML::Node.new "linkingAgentIdentifierType", linkingAgentIdentifier
      linkingAgentIdentifierType.content = eventdata["tool"]
      linkingAgentIdentifierValue = Nokogiri::XML::Node.new "linkingAgentIdentifierValue", linkingAgentIdentifier
      linkingAgentIdentifierValue.content = eventdata["version"]
      linkingAgentIdentifier.add_child(linkingAgentIdentifierType)
      linkingAgentIdentifier.add_child(linkingAgentIdentifierValue)
      eventOutcomeInformation.add_child(eventOutcome)
      event.add_child(eventType)
      event.add_child(eventDateTime)
      event.add_child(eventDetail)
      event.add_child(eventOutcomeInformation)
      event.add_child(linkingAgentIdentifier)
      xmlData.add_child(event)
      mdWrap.add_child(xmlData)
      b.add_child(mdWrap)
      node.add_child(b)
    end

    return doc.to_xml    
  end
  
  def insert_supplement(metsxml, filedata)
    doc = Nokogiri::XML(metsxml)
    doc.xpath('//mets:mets/mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods').each do |node|
      b = Nokogiri::XML::Node.new "relatedItem", doc
      b['displayLabel'] = "Supplemental File"
      b['type'] = "constituent"
      titleInfo = Nokogiri::XML::Node.new "titleInfo", b
      title = Nokogiri::XML::Node.new "title", titleInfo
      title.content = filedata.label
      identifier = Nokogiri::XML::Node.new "identifier", b
      identifier['type'] = "local search"
      identifier.content = filedata.id
      titleInfo.add_child(title)
      b.add_child(titleInfo)
      b.add_child(identifier)
      node.add_child(b)
    end

    doc.xpath('//mets:mets/mets:structMap/mets:div').each do |node|
      fptr = Nokogiri::XML::Node.new "fptr", doc
      fptr['FILEID'] = filedata.id
      node.add_child(fptr)
    end

    return doc.to_xml
  end

  def insert_fitsinfo(metsxml, fitsxml, filedata)
    @doc = Nokogiri::XML(fitsxml)
    @identity = @doc.xpath('//xmlns:identification/xmlns:identity')
    mimetype = @identity[0]['mimetype']
    attrlist = ['mimetype', '*']

    whitelist = Rails.configuration.x.fits_export_whitelist

    toollist = []
    for child in @identity.children
      if child['toolname'] != nil && whitelist.keys.include?(child['toolname'].to_sym)
        for attr in whitelist[child['toolname'].to_sym]
          if attrlist.include?(attr)
            toollist.push( child['toolname'] )
          end
        end
      end
    end

    metsdoc = Nokogiri::XML(metsxml)
    metsdoc.xpath('//mets:mets/mets:fileSec').each do |node|
      for tool in toollist.uniq
        fileGrp = Nokogiri::XML::Node.new "fileGrp", metsdoc
        fileGrp['USE'] = tool
        file = Nokogiri::XML::Node.new "file", fileGrp
        file['ID'] = filedata.id
        file['MIMETYPE'] = mimetype
        file['SEQ'] = "1"
        file['GROUPID'] = "GID1"
        linktype = Nokogiri::XML::Node.new "FLocat", file
        linktype['xlink:href'] = ""
        linktype['LOCTYPE'] = "URL"
        file.add_child(linktype)
        fileGrp.add_child(file)
        node.add_child(fileGrp)
      end
    end

    return metsdoc.to_xml
  end

  def create_proquest_xml(pqjson, filename)

    result = JSON.parse(pqjson)

    #all info
    authorinfo = result["DISS_submission"]["DISS_authorship"]["DISS_author"]
    dissinfo = result["DISS_submission"]["DISS_description"]
    disscontent = result["DISS_submission"]["DISS_content"]
    cmteinfo = dissinfo["DISS_cmte_member"]
    catinfo = dissinfo["DISS_categorization"]

    doc = File.open("config/pqtemplate.xml") { |f| Nokogiri::XML(f) }
    doc.xpath('//DISS_submission/DISS_authorship/DISS_author/DISS_name').each do |node|

      node.children.each do |child|
        case child.name
        when 'DISS_surname'
          child.content = authorinfo["DISS_name"]["DISS_surname"]
        when 'DISS_fname'
          child.content = authorinfo["DISS_name"]["DISS_fname"]
        when 'DISS_middle'
          child.content = authorinfo["DISS_name"]["DISS_middle"]
        when 'DISS_affiliation'
          child.content = authorinfo["DISS_name"]["DISS_affiliation"]
        when 'DISS_suffix'
          child.content = authorinfo["DISS_name"]["DISS_suffix"]
        end
      end

    end

    doc.xpath('//DISS_submission/DISS_authorship/DISS_author/DISS_contact').each do |node|

      node.children.each do |child|
        case child.name
        when 'DISS_contact_effdt'
          child.content = authorinfo["DISS_contact"]["DISS_contact_effdt"]
        when 'DISS_email'
          child.content = authorinfo["DISS_contact"]["DISS_email"]
        end
      end

    end

    doc.xpath('//DISS_submission/DISS_authorship/DISS_author/DISS_contact/DISS_phone_fax').each do |node|

      node.children.each do |child|
        case child.name
        when 'DISS_cntry_cd'
          child.content = authorinfo["DISS_contact"]["DISS_phone_fax"]["DISS_cntry_cd"]
        when 'DISS_area_code'
          child.content = authorinfo["DISS_contact"]["DISS_phone_fax"]["DISS_area_code"]
        when 'DISS_phone_num'
          child.content = authorinfo["DISS_contact"]["DISS_phone_fax"]["DISS_phone_num"]
        when 'DISS_phone_ext'
          child.content = authorinfo["DISS_contact"]["DISS_phone_fax"]["DISS_phone_ext"]
        end
      end

    end

    doc.xpath('//DISS_submission/DISS_authorship/DISS_author/DISS_contact/DISS_address').each do |node|

      node.children.each do |child|
        case child.name
        when 'DISS_addrline'
          child.content = authorinfo["DISS_contact"]["DISS_address"]["DISS_addrline"]
        when 'DISS_city'
          child.content = authorinfo["DISS_contact"]["DISS_address"]["DISS_city"]
        when 'DISS_st'
          child.content = authorinfo["DISS_contact"]["DISS_address"]["DISS_st"]
        when 'DISS_pcode'
          child.content = authorinfo["DISS_contact"]["DISS_address"]["DISS_pcode"]
        when 'DISS_country'
          child.content = authorinfo["DISS_contact"]["DISS_address"]["DISS_country"]
        end
      end

    end

    doc.xpath('//DISS_submission/DISS_description').each do |node|

      node.children.each do |child|
        case child.name
        when 'DISS_title'
          child.content = dissinfo["DISS_title"]
        when 'DISS_degree'
          child.content = dissinfo["DISS_degree"]
        end
      end

    end

    doc.xpath('//DISS_submission/DISS_description/DISS_dates').each do |node|

      node.children.each do |child|
        case child.name
        when 'DISS_comp_date'
          child.content = dissinfo["DISS_dates"]["DISS_comp_date"]
        when 'DISS_accept_date'
          child.content = dissinfo["DISS_dates"]["DISS_accept_date"]
        end
      end

    end

    doc.xpath('//DISS_submission/DISS_description/DISS_institution').each do |node|

      node.children.each do |child|
        case child.name
        when 'DISS_inst_code'
          child.content = dissinfo["DISS_institution"]["DISS_inst_code"]
        when 'DISS_inst_name'
          child.content = dissinfo["DISS_institution"]["DISS_inst_name"]
        when 'DISS_inst_contact'
          child.content = dissinfo["DISS_institution"]["DISS_inst_contact"]
        end
      end

    end

    doc.xpath('//DISS_submission/DISS_description/DISS_advisor/DISS_name').each do |node|

      node.children.each do |child|
        case child.name
        when 'DISS_surname'
          child.content = dissinfo["DISS_advisor"]["DISS_name"]["DISS_surname"]
        when 'DISS_fname'
          child.content = dissinfo["DISS_advisor"]["DISS_name"]["DISS_fname"]
        when 'DISS_middle'
          child.content = dissinfo["DISS_advisor"]["DISS_name"]["DISS_middle"]
        when 'DISS_affiliation'
          child.content = dissinfo["DISS_advisor"]["DISS_name"]["DISS_affiliation"]
        when 'DISS_suffix'
          child.content = dissinfo["DISS_advisor"]["DISS_name"]["DISS_suffix"]
        end
      end

    end


    doc.xpath('//DISS_submission/DISS_description/DISS_cmte_member').each do |node|

      for cm in cmteinfo
        b = Nokogiri::XML::Node.new "DISS_name", doc
        bsurname = Nokogiri::XML::Node.new "DISS_surname", b
        bsurname.content = cm["DISS_name"]["DISS_surname"]
        bfname = Nokogiri::XML::Node.new "DISS_fname", b
        bfname.content = cm["DISS_name"]["DISS_fname"]
        bmiddle = Nokogiri::XML::Node.new "DISS_middle", b
        bmiddle.content = cm["DISS_name"]["DISS_middle"]
        bsuffix = Nokogiri::XML::Node.new "DISS_suffix", b
        bsuffix.content = cm["DISS_name"]["DISS_suffix"]
        baffiliation = Nokogiri::XML::Node.new "DISS_affiliation", b
        baffiliation.content = cm["DISS_name"]["DISS_affiliation"]

        b.add_child(bsurname)
        b.add_child(bfname)
        b.add_child(bmiddle)
        b.add_child(bsuffix)
        b.add_child(baffiliation)
        node.add_child(b)
      end

    end

    doc.xpath('//DISS_submission/DISS_description/DISS_categorization').each do |node|

      for cm in catinfo["DISS_categories"]
        b = Nokogiri::XML::Node.new "DISS_category", doc
        bcatcode = Nokogiri::XML::Node.new "DISS_cat_code", b
        bcatcode.content = cm["DISS_category"]["DISS_cat_code"]
        bcatdesc = Nokogiri::XML::Node.new "DISS_cat_desc", b
        bcatdesc.content = cm["DISS_category"]["DISS_cat_desc"]

        b.add_child(bcatcode)
        b.add_child(bcatdesc)
        node.add_child(b)
      end

      b = Nokogiri::XML::Node.new "DISS_keyword", doc
      b.content = catinfo["DISS_keyword"]
      node.add_child(b)

      b = Nokogiri::XML::Node.new "DISS_language", doc
      b.content = catinfo["DISS_language"]
      node.add_child(b)

    end

    doc.xpath('//DISS_submission/DISS_content').each do |node|

      node.children.each do |child|
        case child.name
        when 'DISS_abstract'

          child.children.each do |newchild|
            case newchild.name
            when 'DISS_para'
              newchild.content = disscontent["DISS_abstract"]["DISS_para"]
            end
          end

        when 'DISS_binary'
          child.content = filename
        end
      end

    end

    return doc.to_xml
  end

  def export_bagit
    collection_id = params[:id]
    collection = Collection.find(collection_id)
    collection_attributes = collection.title
    namespaces = {"xmlns:mets" => "http://www.loc.gov/METS/",
      "xmlns:mods" => "http://www.loc.gov/mods/v3",
      "xmlns:rts" => "http://cosimo.stanford.edu/sdr/metsrights/",
      "xmlns:mix" => "http://www.loc.gov/mix/v10",
      "xmlns:premis" => "info:lc/xmlns/premis-v2",
      "xmlns:xlink" => "http://www.w3.org/1999/xlink",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation" => "http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd http://cosimo.stanford.edu/sdr/metsrights/ http://cosimo.stanford.edu/sdr/metsrights.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd http://www.loc.gov/mix/v10 http://www.loc.gov/standards/mix/mix10/mix10.xsd",
      "OBJID" => "ark:/13030/hb4199p148",
      "LABEL" => "Extending the Lexicon by Exploiting Subregularities",
      "PROFILE" => "http://www.loc.gov/mets/profiles/00000013.xml"
    }
    @bag_file = collection_id + '_bagit.tar.gz'

    unless authorize_export(collection)
      render status: 401 and return
    end

    # create temp folder
    Dir.mktmpdir do |dir|
      # create Mets file
      mets_filename = collection_id + "_mets.xml"
      mets_filepath = dir + "/" + mets_filename
      metsxml = create_mets(collection, namespaces)

      # bagit path
      bagit_path = dir + "/" + collection_id + "_bag/"
      bag = BagIt::Bag.new bagit_path

      eventnum = 1
      collection.member_ids.each do |doc_id|
        # get file and save to temp folder
        fileObj = GenericFile.find(doc_id)
        fileurl = fileObj.content.uri
        filename = fileObj.label
        open(dir + "/" + filename, 'wb') do |file|
          file << open(fileurl).read
        end

        # Virus scan
        unless fileObj.ondemand_detect_viruses
          render status: 500
        else
          toolinfo = Rails.configuration.x.clamav_version.split(/[\s\/']/)
          metsxml = insert_event(metsxml, "event" + eventnum.to_s, filename, Time.now.strftime("%m/%d/%Y %H:%M"), Rails.configuration.x.virus_pass_message, Rails.configuration.x.successful_message, toolinfo[0], toolinfo[1])
          eventnum += 1
        end

        # PII scan
        unless fileObj.ondemand_detect_pii
          render status: 500
        else
          toolinfo = Rails.configuration.x.bulk_extractor_version.split(" ")
          metsxml = insert_event(metsxml, "event" + eventnum.to_s, filename, Time.now.strftime("%m/%d/%Y %H:%M"), Rails.configuration.x.pii_pass_message, Rails.configuration.x.successful_message, toolinfo[0], toolinfo[1]) 
          eventnum += 1
        end

        # XML validate scan
        if !fileObj.ondemand_validate_xml && Rails.configuration.x.stop_xml_export
          render status: 500
        else
          toolinfo = Rails.configuration.x.nokogiri_version.split(":")
          metsxml = insert_event(metsxml, "event" + eventnum.to_s, filename, Time.now.strftime("%m/%d/%Y %H:%M"), Rails.configuration.x.xml_pass_message, Rails.configuration.x.successful_message, toolinfo[0], toolinfo[1].strip!) 
          eventnum += 1
        end

        # append Fits info
        metsxml = insert_supplement(metsxml, fileObj)
        metsxml = insert_fitsinfo(metsxml, fileObj.content.extract_metadata, fileObj)

        # add file to bagit
        if !File.file?(bagit_path + "data/" + filename)
          bag.add_file(filename, dir + "/" + filename)
          bag.manifest!
        end
      end

      File.open(mets_filepath, 'w') { |file| file.write(metsxml) }

      if !File.file?(bagit_path + "data/" + mets_filename)
        bag.add_file(mets_filename, mets_filepath)
        bag.manifest!
      end

      system("tar -zcvf #{@bag_file} -C #{dir}/#{collection_id}_bag .")

      send_file @bag_file
    end
  end

  def bagit_download
    @collection = Collection.find(params[:id])

    unless authorize_export(@collection)
      render status: 401 and return
    end
  end

  def export_proquest

    collection_id = params[:id]
    collection = Collection.find(collection_id)
    unless collection.has_one_main_etd?
      flash[:error] ||= "This collection does have exactly one ProQuest Main ETD PDF file."
      redirect_to collections.collection_path(collection)
      return
    end

    # get pqjson and create proquest xml
    pqjson = collection.proquest_inputs

    result = JSON.parse(pqjson)
    authorinfo = result["DISS_submission"]["DISS_authorship"]["DISS_author"]

    newfilename = authorinfo["DISS_name"]["DISS_surname"] +"_" + authorinfo["DISS_name"]["DISS_fname"]

    # validate filename
    newfilename = Zaru.sanitize!(newfilename)

    # create proguest filename and validate that filename
    @proquest_file = "upload_" + newfilename + ".zip"

    unless authorize_export(collection)
      render status: 401 and return
    end

    # create temp folder
    Dir.mktmpdir do |dir|

      # ProQuest path
      proquest_path = dir + "/" + collection_id + "/upload_name/"
      proquest_media_path = proquest_path + "name_media/"

      unless File.directory?(proquest_path)
        FileUtils.mkdir_p(proquest_path)
      end

      unless File.directory?(proquest_media_path)
        FileUtils.mkdir_p(proquest_media_path)
      end

      collection.member_ids.each do |doc_id|
        # get file and save to temp folder
        fileObj = GenericFile.find(doc_id)
        fileurl = fileObj.content.uri
        filename = fileObj.label
        open(dir + "/" + filename, 'wb') do |file|
          file << open(fileurl).read
        end

        # Virus scan
        unless fileObj.ondemand_detect_viruses
          render status: 500
        end

        # PII scan
        unless fileObj.ondemand_detect_pii
          render status: 500
        end

        # XML validate scan
        if !fileObj.ondemand_validate_xml && Rails.configuration.x.stop_xml_export
          render status: 500
        end

        # add ProQuest main file to ProQuest path
        if (fileObj.resource_type.include? "ProQuest Main ETD PDF")
          # change main etd pdf filename
          FileUtils.mv dir + "/" + filename, proquest_path + newfilename + ".pdf"
        else
          # add other files to ProQuest media path
          FileUtils.mv dir + "/" + filename, proquest_media_path
        end

      end

      # create proquest xml
      pqcontents = create_proquest_xml(pqjson, newfilename + ".pdf")

      mets_filepath = newfilename + ".xml"
      File.open(mets_filepath, 'w') { |file| file.write(pqcontents) }
      FileUtils.mv mets_filepath, proquest_path

      Dir.chdir(proquest_path) do
        system("zip -r #{collection_id}_archive.zip -D *")
      end

      FileUtils.mv proquest_path + "/#{collection_id}_archive.zip", @proquest_file

      send_file @proquest_file
    end

  end

  def scan_viruses
    logger.error("#{require  'sufia/models/virus_found_error'}")
    @collection = Collection.find(params[:id])
    @found_viruses = []
    @collection.members.each do |gf|
      unless gf.ondemand_detect_viruses(true)
        @found_viruses << gf.filename
      end
    end
    if @found_viruses.empty?
      flash[:notice] = "No viruses found!"
    else
      flash[:alert] = "Found viruses in files: #{@found_viruses.join(',')}! \n Corresponding actions have been taken."
    end
    respond_to do |format|
      format.html { redirect_to collections.collection_path(@collection)}
    end
  end

  protected
    def collection_params
      form_class.model_attributes(
        params.require(:collection).permit(:title, :description, :members, :rights, :proquest_inputs,
                                           part_of: [], contributor: [], creator: [],
                                           publisher: [], date_created: [], subject: [],
                                           language: [], resource_type: [], identifier: [],
                                           based_near: [], tag: [], related_url: [])
        )
    end
    
  private

    def authorize_export(collection)
      if Rails.configuration.x.ip_whitelist.include?(request.remote_ip)
        true
      end

      authorize! :edit, collection
    end
end
