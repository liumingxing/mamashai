class AddIsBookToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :is_book, :boolean, :default=>false
  end
  
  def self.down
    remove_column :posts, :is_book
  end
end
