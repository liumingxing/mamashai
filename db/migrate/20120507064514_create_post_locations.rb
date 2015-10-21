class CreatePostLocations < ActiveRecord::Migration
  def self.up
    create_table :post_locations do |t|
      t.integer :post_id
      t.string :longitude
      t.string :latitude
      t.timestamps
    end

    add_index :post_locations, :post_id
  end

  def self.down
    drop_table :post_locations
  end
end
