class AddUsingBalanceToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :using_balance, :float, :default=>0.0
  end

  def self.down
    remove_column :orders, :using_balance
  end
end
