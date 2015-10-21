class AddViewCountToAlbumBook < ActiveRecord::Migration
  def self.up
  	add_column :album_books, :view_count, :integer, :default=>0
  end

  def self.down
  end
end
