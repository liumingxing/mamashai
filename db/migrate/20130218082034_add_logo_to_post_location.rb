class AddLogoToPostLocation < ActiveRecord::Migration
  def self.up
  	add_column :post_locations, :logo, :string
  end

  def self.down
  end
end
