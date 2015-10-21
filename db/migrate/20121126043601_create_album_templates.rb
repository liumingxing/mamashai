class CreateAlbumTemplates < ActiveRecord::Migration
  def self.up
    create_table :album_templates do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :album_templates
  end
end
