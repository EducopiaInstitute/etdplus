class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  skip_load_and_authorize_resource :only => [:export_bagit]


  def show
      super
  end

  def export_bagit
	base_path = "/tmp/"
	collection_id = params[:id]
	collection = Collection.find(collection_id)
	collection_attributes = collection.title

	# create temp folder
	temp_folder = base_path + collection_id + "_tmp/"
	Dir.mkdir(temp_folder) unless File.exists?(temp_folder)

	# create Mets file
	mets_filename = collection_id + ".txt"
	mets_filepath = temp_folder + mets_filename
	File.open(mets_filepath, 'w') { |file| file.write(collection_attributes) }

	# bagit path
	bagit_path = base_path + collection_id + "_bag/" 
	bag = BagIt::Bag.new bagit_path

	collection.member_ids.each do |doc_id|
		# get file and save to temp folder
		fileObj = GenericFile.find(doc_id)
		fileurl = fileObj.content.uri
		filename = fileObj.filename[0]
		open(temp_folder+filename, 'wb') do |file|
			file << open(fileurl).read
		end

		# virus scan
		if fileObj.detect_viruses
			render status: 500
		end		

		# Pii scan
		#if fileObj.bulk_extractor_inspect
		#	render status: 500
		#end		

		# append Mets file
		File.open(mets_filepath, 'a') { |file| file.write(fileObj.content.extract_metadata) }

		# add file to bagit
		if !File.file?(bagit_path + "data/" + filename)
			bag.add_file(filename, temp_folder+filename)
			bag.manifest!
		end

	end

	if !File.file?(bagit_path + "data/" + mets_filename)
		bag.add_file(mets_filename, mets_filepath)
		bag.manifest!
	end
	
	system("tar -zczf /tmp/#{collection_id}_bagit.tar.gz #{bagit_path}")
	
	FileUtils.rm(mets_filepath)
	FileUtils.rm_rf(bagit_path)
	FileUtils.rm_rf(temp_folder)

	send_file '/tmp/'+collection_id+'_bagit.tar.gz'

  end

end
