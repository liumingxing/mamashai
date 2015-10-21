class AddPositionToAlbumTemplatePage < ActiveRecord::Migration
  def self.up
  	add_column :album_template_pages, :position, :integer, :default=>1
  end

  def self.down
  end
end
