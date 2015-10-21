class AddIndexToSpots < ActiveRecord::Migration
  def self.up
    add_index :spots, :province_id
    add_index :spots, :city_id
    add_index :spots, :spot_tag_id
    add_index :spots, :post_id
    add_index :spots, :user_id
  end

  def self.down
    remove_index :spots, :province_id
    remove_index :spots, :city_id
    remove_index :spots, :spot_tag_id
    remove_index :spots, :post_id
    remove_index :spots, :user_id  
  end
end
