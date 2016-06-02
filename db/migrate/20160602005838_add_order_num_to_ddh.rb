class AddOrderNumToDdh < ActiveRecord::Migration
  def change
    add_column :ddhs, :order_num, :integer, default: 0
  end
end
