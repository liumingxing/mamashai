class AddFmColorToAlbumTemplates < ActiveRecord::Migration
  def self.up
    add_column :album_templates, :color, :string
  end

  def self.down
  end
end
