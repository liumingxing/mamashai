class AddUrlToMmstools < ActiveRecord::Migration
  def self.up
    add_column :mms_tools, :url, :string, :limit=>100
  end

  def self.down
    remove_column :mms_tools, :url
  end
end
