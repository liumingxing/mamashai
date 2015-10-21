class AddRateToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :rate, :integer
    add_column :eproducts, :rate, :integer
    add_column :eproducts, :brand, :string,:limit=>100
  end
  
  def self.down
    remove_column :comments, :rate
    remove_column :eproducts, :rate
    remove_column :eproducts, :brand
  end
end
