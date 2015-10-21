class AddCategoryToColumnAuthors < ActiveRecord::Migration
  def self.up
    add_column :column_authors, :category, :string
  end

  def self.down
  end
end
