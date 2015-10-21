class CreateAlbumBooks < ActiveRecord::Migration
  def self.up
    create_table :album_books do |t|
      t.integer :user_id
      t.string 	:name
      t.string :logo
      t.text 	:content
      t.integer :template_id
      t.timestamps
    end
  end

  def self.down
    drop_table :album_books
  end
end
