class AddTpToMmsApps < ActiveRecord::Migration
  def self.up
    add_column :mms_apps, :tp, :integer,:default=>0
  end

  def self.down
    remove_column :mms_apps, :tp
  end
end
