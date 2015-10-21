class AddLogoToAlbumTempates < ActiveRecord::Migration
  def self.up
  	add_column :album_templates, :logo, :string
  end

  def self.down
  end
end
