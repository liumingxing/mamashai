class AddLongitudeAndLatitudeToCity < ActiveRecord::Migration
  def self.up
    add_column :cities, :longitude, :float
    add_column :cities, :latitude, :float
  end

  def self.down
    remove_column :cities, :latitude
    remove_column :cities, :longitude
  end
end
