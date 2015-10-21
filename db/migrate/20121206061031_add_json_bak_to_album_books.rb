class AddJsonBakToAlbumBooks < ActiveRecord::Migration
  def self.up
  	add_column :album_books, :json_bak, :longtext
  end

  def self.down
  end
end
