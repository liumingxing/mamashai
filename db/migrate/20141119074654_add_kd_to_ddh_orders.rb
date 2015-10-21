class AddKdToDdhOrders < ActiveRecord::Migration
  def change
  	add_column :ddh_orders, :kd_sn, :string
  end
end
