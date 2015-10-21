class AddNotifyIgnoresToUserProfiles < ActiveRecord::Migration
  def self.up
    add_column :user_profiles, :notify_ignores, :string, :limit=>100,:default=>''
  end

  def self.down
  end
end
