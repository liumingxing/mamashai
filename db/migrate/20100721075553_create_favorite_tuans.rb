class CreateFavoriteTuans < ActiveRecord::Migration
  def self.up
    create_table :favorite_tuans do |t|
      t.integer :tuan_id
      t.integer :user_id
      t.text :content
      t.datetime :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :favorite_tuans
  end
end
