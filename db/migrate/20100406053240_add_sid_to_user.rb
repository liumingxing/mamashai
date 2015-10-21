class AddSidToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :sid, :string
  end

  def self.down
    remove_column :users, :sid
  end
end
