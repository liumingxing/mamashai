class AddTuanWebsiteIdToTuanComments < ActiveRecord::Migration
  def self.up
    add_column :tuan_comments, :tuan_website_id, :integer
    add_column :tuan_websites, :tuan_comments_count, :integer, :default => 0
    add_column :tuan_websites, :rates_count, :integer, :default => 0
  end

  def self.down
    remove_column :tuan_comments, :tuan_website_id
    remove_column :tuan_website, :tuan_comments_count
    remove_column :tuan_websites, :rates_count
  end
end
