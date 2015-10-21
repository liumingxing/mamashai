class AddTypeToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :type, :string
    Order.update_all("type='BookOrder'")
  end

  def self.down
    remove_column :orders, :type
  end
end
