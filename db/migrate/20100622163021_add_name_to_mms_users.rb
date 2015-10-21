class AddNameToMmsUsers < ActiveRecord::Migration
  def self.up
    add_column :mms_users, :name, :string
  end

  def self.down
    remove_column :mms_users, :name
  end
end
