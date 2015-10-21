class AddFromToPost < ActiveRecord::Migration
  def self.up
     add_column :posts, :from, :string, :limit=>100
     add_column :posts, :from_id, :integer
  end

  def self.down
    remove_column :posts, :from
    remove_column :posts, :from_id
  end
end
