class AddIsHideToSpot < ActiveRecord::Migration
  def self.up
    add_column :spots, :is_hide, :boolean
  end

  def self.down
    remove_column :spots, :is_hide
  end
end
