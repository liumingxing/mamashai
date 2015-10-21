class AddPriceToEproducts < ActiveRecord::Migration
  def self.up
    add_column :eproducts, :price, :float
  end
  
  def self.down
    remove_column :eproducts, :price
  end
end
