Rails.application.routes.draw do
  get 'deposit_plan', to: 'static#deposit_plan'
  get 'file_feedback', to: 'static#file_feedback'
  get 'collections/:id/download', to: 'collections#bagit_download' , as: 'bagit_download'
  get 'collections/:id/export_bagit', to: 'collections#export_bagit' , as: 'export_bagit'
  get 'collections/:id/export_proquest', to: 'collections#export_proquest' , as: 'export_proquest_collection'
  blacklight_for :catalog
  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'

  Hydra::BatchEdit.add_routes(self)
  # This must be the very last route in the file because it has a catch-all route for 404 errors.
  # This behavior seems to show up only in production mode.
  mount Sufia::Engine => '/'
  root to: 'homepage#index'
end
