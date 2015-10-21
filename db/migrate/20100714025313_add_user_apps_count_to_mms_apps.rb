class AddUserAppsCountToMmsApps < ActiveRecord::Migration
  def self.up
    add_column :mms_apps, :user_apps_count, :integer, :default=>0
  end

  def self.down
    remove_column :mms_apps, :user_apps_count
  end
end
