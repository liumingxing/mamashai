class AddColumnDefaultPositionToMmsApp < ActiveRecord::Migration
  def self.up
    add_column :mms_apps, :default_position, :integer
  end

  def self.down
    remove_column :mms_apps, :default_position
  end
end
