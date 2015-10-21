class AddUserActionsToUserProfiles < ActiveRecord::Migration
  def self.up
    add_column :user_profiles, :user_actions, :string, :limit=>100,:default=>''
  end

  def self.down
  end
end
