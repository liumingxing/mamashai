class AddTitleToPostLocation < ActiveRecord::Migration
  def self.up
  	add_column :post_locations, :title, :string
  end

  def self.down
  end
end
