class AddRealNameToEventUsers < ActiveRecord::Migration
  def self.up
    add_column :event_users, :real_name, :string
  end

  def self.down
    remove_column :event_users, :real_name
  end
end
