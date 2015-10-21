class AddStatusToDdhOrders < ActiveRecord::Migration
  def self.up
  	add_column :ddh_orders, :status, :string
  end

  def self.down
  end
end
