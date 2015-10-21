class AddBlogTagsAndVisibleToPost < ActiveRecord::Migration
  def self.up
    add_column :long_posts, :blog_tags, :string, :limit=>200
    add_column :long_posts, :blog_visible, :string, :limit=>20, :default=>"public"
    add_column :long_posts, :draft, :boolean, :default=>false
    add_column :long_posts, :top, :boolean, :default=>false
  end

  def self.down
  end
end
