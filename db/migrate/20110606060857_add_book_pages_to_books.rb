class AddBookPagesToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :book_pages, :string
  end

  def self.down
    remove_column :books, :book_pages
  end
end
