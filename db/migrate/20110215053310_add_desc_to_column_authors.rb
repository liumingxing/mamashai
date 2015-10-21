class AddDescToColumnAuthors < ActiveRecord::Migration
  def self.up
    add_column :column_authors, :desc, :text
  end

  def self.down
    remove_column :column_authors, :desc
  end
end
