class CreateSpots < ActiveRecord::Migration
  def self.up
    create_table :spots do |t|
      t.string :name,:limit=>100
      t.integer :province_id
      t.integer :city_id
      t.integer :spot_tag_id
      t.string :location,:limit=>300
      t.integer :tp
      t.float :longitude
      t.float :latitude
      t.integer :post_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :spots
  end
end
