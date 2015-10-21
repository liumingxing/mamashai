class CreateAlbumPages < ActiveRecord::Migration
  def self.up
    create_table :album_pages do |t|
      t.integer :user_id
      t.string :logo
      t.timestamps
    end
  end

  def self.down
    drop_table :album_pages
  end
end
