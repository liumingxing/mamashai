class AddHasGrantToUsers < ActiveRecord::Migration
  def self.up
	add_column :users,:has_grant,:boolean,:default=>false
  end

  def self.down
	remove_column :users,:has_grant
  end
end
