class AddImgToColumnauthor < ActiveRecord::Migration
  def self.up
    add_column :column_authors, :img, :string
  end

  def self.down
    remove_column :column_authors, :img
  end
end
