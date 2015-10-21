class AddMmsToolsDownload < ActiveRecord::Migration
  def self.up
    create_table :mms_tools_downloads do |t|
      t.integer :user_id
      t.integer :tool_id
      t.datetime :created_at
    end
    
    add_index :mms_tools_downloads, [:user_id, :tool_id]
  end

  def self.down
    drop_table :mms_tools_downloads
  end
end
