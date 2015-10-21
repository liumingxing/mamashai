class AddIsValidateToUsers < ActiveRecord::Migration
  def self.up
    add_column :user_profiles, :uuid, :string, :limit=>50
    add_column :user_profiles, :password_reset, :string,:limit=>35
  end

  def self.down
    remove_column :users, :is_validate
  end
end
