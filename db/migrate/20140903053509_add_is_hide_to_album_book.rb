class AddIsHideToAlbumBook < ActiveRecord::Migration
  def change
  	add_column :album_books, :is_hide, :boolean, :default=>false
  end
end
