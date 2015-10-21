class CreateUserLocations < ActiveRecord::Migration
  def change
    create_table :user_locations do |t|
      t.integer :user_id
      t.integer :province_id
      t.integer :city_id
      t.timestamps
    end

    add_index :user_locations, [:user_id], :unique=>true
    add_index :user_locations, [:province_id]
    add_index :user_locations, [:city_id]
  end
end
