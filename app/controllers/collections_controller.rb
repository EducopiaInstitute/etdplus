class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  skip_load_and_authorize_resource :only => [:export_bagit]


  def show
      super
     
  end


 # private

  def export_bagit
	base_path = "/tmp/"
	collection_id = params[:id]
	collection = Collection.find(collection_id)
	collection_attributes = collection.title

	# create temp folder
	temp_folder = base_path + collection_id + "_tmp/"

	# create Mets file
	mets_filename = collection_id + ".txt"
	mets_filepath = temp_folder + mets_filename
	File.open(mets_filepath, 'w') { |file| file.write(collection_attributes) }

	# bagit path
	bagit_path = base_path + collection_id + "_bag/" 
	bag = BagIt::Bag.new bagit_path

	collection.memeber_ids.each do |doc_id|
		# get file and save to temp folder
		fileObj = GenericFile.find(doc_id)
		fileurl = fileObj.content.url
		filename = fileObj.filename
		open(temp_folder+filename, 'wb') do |file|
			file << open(fileurl).read
		end
		# virus scan
		
		# append Mets file
		File.open(mets_filepath, 'a') { |file| file.write(fileObj.content.extract_metadata) }

		# add file to bagit
		bag.add_file(filename, temp_folder+filename)
		bag.manifest!

	end
	
	bag.add_file(mets_filename, mets_filepath)
	bag.manifest!

	# delete bagit folder 
	FileUtils.rm(mets_filepath)
	#FileUtils.rm_rf(bagit_path)

	send_data generate_tgz(bagit_path), filename: collectionid + '.tgz'

  end

end
