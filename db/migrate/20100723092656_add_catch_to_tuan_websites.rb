class AddCatchToTuanWebsites < ActiveRecord::Migration
  def self.up
    add_column :tuan_websites, :catch_url, :string
    add_column :tuan_websites, :catch_config, :text
    add_column :tuans, :lng, :string
    add_column :tuans, :lat, :string
    add_column :tuans, :tid, :string
    add_column :tuan_websites, :tuan_temps_count, :integer, :default=>0
  end

  def self.down
    remove_column :tuans, :tid
    remove_column :tuans, :lat
    remove_column :tuans, :lng
    remove_column :tuan_websites, :tuan_temps_count
    remove_column :tuan_websites, :catch_config
    remove_column :tuan_websites, :catch_url
  end
end
