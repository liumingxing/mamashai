class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :name
      t.string :logo
      t.string :content
      t.integer :tp,:default=>0
      t.integer :user_id
      t.integer :album_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
