class AddBookActiveToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :book_active, :text
  end

  def self.down
    remove_column :books, :book_active
  end
end
