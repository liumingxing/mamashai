class AddLongitudeLatitudeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :longitude, :float
    add_column :users, :latitude, :float
    add_column :users, :location, :string
  end

  def self.down
    remove_column :users, :latitude
    remove_column :users, :longitude
    remove_column :users, :location
  end
end
