class AddWeightToOrderItem < ActiveRecord::Migration
  def self.up
    add_column :order_items, :product_weight, :integer,:default=>0
  end

  def self.down
    remove_column :order_items, :product_weight
  end
end
