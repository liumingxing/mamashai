class AddFmToAlbumTempatePage < ActiveRecord::Migration
  def self.up
  	add_column :album_template_pages, :fm, :boolean, :default=>false
  end

  def self.down
  end
end
