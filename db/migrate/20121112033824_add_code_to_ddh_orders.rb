class AddCodeToDdhOrders < ActiveRecord::Migration
  def self.up
  	add_column :ddh_orders, :code, :string
  end

  def self.down
  end
end
