class AddMySkinToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :my_skin, :string, :limit=>250
  end

  def self.down
    remove_column :users, :my_skin
  end
end
