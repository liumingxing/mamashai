class AddFromToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :from, :string, :limit=>10
  end

  def self.down
    remove_column :users, :from
  end
end
