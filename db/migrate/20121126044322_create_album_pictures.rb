class CreateAlbumPictures < ActiveRecord::Migration
  def self.up
    create_table :album_pictures do |t|
      t.string :path
      t.timestamps
    end
  end

  def self.down
    drop_table :album_pictures
  end
end
