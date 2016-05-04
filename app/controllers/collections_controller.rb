class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  skip_load_and_authorize_resource :only => [:export_bagit]

  def create_mets(collection)
  	namespaces = {"xmlns:mets" => "http://www.loc.gov/METS/",
		"xmlns:mods" => "http://www.loc.gov/mods/v3",
		"xmlns:rts" => "http://cosimo.stanford.edu/sdr/metsrights/",
		"xmlns:mix" => "http://www.loc.gov/mix/v10",
		"xmlns:xlink" => "http://www.w3.org/1999/xlink",
		"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
		"xsi:schemaLocation" => "http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd http://cosimo.stanford.edu/sdr/metsrights/ http://cosimo.stanford.edu/sdr/metsrights.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd http://www.loc.gov/mix/v10 http://www.loc.gov/standards/mix/mix10/mix10.xsd",
		"OBJID" => "ark:/13030/hb4199p148",
		"LABEL" => "Extending the Lexicon by Exploiting Subregularities",
		"PROFILE" => "http://www.loc.gov/mets/profiles/00000013.xml"
	}

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
						b[:mods].languageTerm("type" => "code", "authority" => "iso639-2b")	{
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

  def export_bagit
    collection_id = params[:id]
    collection = Collection.find(collection_id)
    collection_attributes = collection.title

    unless authorize_export(collection)
      render status: 401
    end

    # create temp folder
    Dir.mktmpdir do |dir|
      # create Mets file
      mets_filename = collection_id + "_mets.xml"
      mets_filepath = dir + "/" + mets_filename
      metsxml = create_mets(collection)

      # bagit path
      bagit_path = dir + "/" + collection_id + "_bag/"
      bag = BagIt::Bag.new bagit_path

      collection.member_ids.each do |doc_id|
        # get file and save to temp folder
        fileObj = GenericFile.find(doc_id)
        fileurl = fileObj.content.uri
        filename = fileObj.label
        open(dir + "/" + filename, 'wb') do |file|
          file << open(fileurl).read
        end

        # virus scan
        if fileObj.detect_viruses
          render status: 500
        end

        # Pii scan
        #if fileObj.bulk_extractor_scan
        #  render status: 500
        #end

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

      system("tar -zcvf #{collection_id}_bagit.tar.gz -C #{dir}/#{collection_id}_bag .")
      send_file collection_id +'_bagit.tar.gz'
    end
  end

  protected
    def collection_params
      form_class.model_attributes(
        params.require(:collection).permit(:title, :description, :members, :rights,
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
