class AddToolToMmsTools < ActiveRecord::Migration
  def self.up
    add_column :mms_tools, :tool, :boolean, :default=>false
  end

  def self.down
    remove_column :mms_tools, :tool
  end
end
