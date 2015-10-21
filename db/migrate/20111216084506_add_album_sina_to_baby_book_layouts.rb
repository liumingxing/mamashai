class AddAlbumSinaToBabyBookLayouts < ActiveRecord::Migration
  def self.up
    add_column :baby_book_layouts, :album_sina, :boolean, :default=>false
  end

  def self.down
  end
end
