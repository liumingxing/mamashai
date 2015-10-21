class AddScoreActionsToUserProfiles < ActiveRecord::Migration
  def self.up
    add_column :user_profiles, :score_actions, :string, :limit=>300
    add_column :users, :company, :string, :limit=>25
    remove_column :user_profiles, :company
  end
  
  def self.down
  end
  
end
