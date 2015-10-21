class AddPicturesNaProfile < ActiveRecord::Migration
  def self.up
    add_column :na_profiles, :picture1, :string, :limit=>100
    add_column :na_profiles, :picture2, :string, :limit=>100
    add_column :na_profiles, :picture3, :string, :limit=>100
    add_column :na_profiles, :picture4, :string, :limit=>100
    add_column :na_profiles, :picture5, :string, :limit=>100
  end

  def self.down
    remove_column :na_profiles, :picture1
    remove_column :na_profiles, :picture2
    remove_column :na_profiles, :picture3
    remove_column :na_profiles, :picture4
    remove_column :na_profiles, :picture5
  end
end
