class AddLikeCountsToAlbumBooks < ActiveRecord::Migration
  def self.up
  	add_column :album_books, :like_count, :integer, :default=>0
  	add_column :album_books, :comment_count, :integer, :default=>0
  end

  def self.down
  end
end
