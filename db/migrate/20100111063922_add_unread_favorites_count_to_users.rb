class AddUnreadFavoritesCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :unread_favorites_count, :integer, :default=>0
    add_column :favorite_posts, :content, :string, :limit=>210
    add_column :favorite_posts, :created_at, :datetime
  end

  def self.down
  end
end
