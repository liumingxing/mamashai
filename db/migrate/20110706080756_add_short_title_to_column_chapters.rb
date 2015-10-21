class AddShortTitleToColumnChapters < ActiveRecord::Migration
  def self.up
    add_column :column_chapters, :short_title, :string
  end

  def self.down
    remove_column :column_chapters, :short_title
  end
end
