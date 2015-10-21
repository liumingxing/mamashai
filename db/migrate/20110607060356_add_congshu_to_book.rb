class AddCongshuToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :series_book_name,:string
  end

  def self.down
    remove_column :books, :series_book_name
  end
end
