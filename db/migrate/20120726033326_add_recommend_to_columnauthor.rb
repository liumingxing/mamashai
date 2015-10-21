class AddRecommendToColumnauthor < ActiveRecord::Migration
  def self.up
    add_column :column_authors, :recommend, :integer
  end

  def self.down
    remove_column :column_authors, :recommend
  end
end
