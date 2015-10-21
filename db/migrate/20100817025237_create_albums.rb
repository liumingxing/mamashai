class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.string :name
      t.string :logo
      t.string :content
      t.integer :tp,:default=>0
      t.integer :pictures_count,:default=>0
      t.integer :comments_count,:default=>0
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :albums
  end
end
