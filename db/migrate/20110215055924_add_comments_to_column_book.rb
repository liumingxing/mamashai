class AddCommentsToColumnBook < ActiveRecord::Migration
  def self.up
    add_column :column_books, :comments, :integer, :default=>0
    add_column :column_books, :fowards, :integer, :default=>0
    add_column :column_books, :favorites, :integer, :default=>0
  end

  def self.down
    remove_column :column_books, :comments
    remove_column :column_books, :fowards
    remove_column :column_books, :favorites
  end
end
