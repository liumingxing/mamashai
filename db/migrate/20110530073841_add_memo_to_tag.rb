class AddMemoToTag < ActiveRecord::Migration
  def self.up
    add_column :tags, :memo, :text
  end

  def self.down
    remove_column :tags, :memo
  end
end
