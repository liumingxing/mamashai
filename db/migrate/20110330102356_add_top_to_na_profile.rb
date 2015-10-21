class AddTopToNaProfile < ActiveRecord::Migration
  def self.up
    add_column :na_profiles, :top, :boolean, :default=>false, :null=>true
  end

  def self.down
    remove_column :na_profiles, :top
  end
end
