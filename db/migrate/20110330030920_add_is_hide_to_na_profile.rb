class AddIsHideToNaProfile < ActiveRecord::Migration
  def self.up
    add_column :na_profiles, :is_hide, :boolean, :default=>false, :null=>true
  end

  def self.down
    remove_column :na_profiles, :is_hide
  end
end
