class AddTuanIdToMmsTools < ActiveRecord::Migration
  def self.up
    add_column :mms_tools, :tuan_id, :integer
  end

  def self.down
    remove_column :mms_tools, :tuan_id
  end
end
