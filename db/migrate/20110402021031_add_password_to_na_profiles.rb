class AddPasswordToNaProfiles < ActiveRecord::Migration
  def self.up
    add_column :na_profiles, :password, :string, :limit=>30
  end

  def self.down
    remove_column :na_profiles, :password
  end
end
