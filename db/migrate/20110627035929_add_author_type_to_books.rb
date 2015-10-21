class AddAuthorTypeToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :author_type, :string
  end

  def self.down
    remove_column :book, :author_type
  end
end
