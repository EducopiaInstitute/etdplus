class Ability
  include Hydra::Ability
  include Sufia::Ability

  
  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    end
  end

  def generic_file_abilities
    can :view_share_work, [GenericFile]
    can :create, [GenericFile, Collection] if registered_user?
  end
end
