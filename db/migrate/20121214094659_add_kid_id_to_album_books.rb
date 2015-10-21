class AddKidIdToAlbumBooks < ActiveRecord::Migration
  def self.up
  	add_column :album_books, :kid_id, :integer
  end

  def self.down
  end
end
