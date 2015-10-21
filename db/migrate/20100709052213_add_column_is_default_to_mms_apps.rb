class AddColumnIsDefaultToMmsApps < ActiveRecord::Migration
  def self.up
    add_column :mms_apps, :is_default, :boolean, :default => false
    add_column :mms_apps, :sub_link_name, :string
    add_column :mms_apps, :sub_link, :string
  end

  def self.down
    remove_column :mms_apps, :is_default
    remove_column :mms_apps, :sub_link
    remove_column :mms_apps, :sub_link_name
  end
end
