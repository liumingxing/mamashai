class AddExpressInfoToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :express_company, :string
    add_column :orders, :express_order_id, :string
    add_column :orders, :express_at, :datetime
  end

  def self.down
    remove_column :orders, :express_company
    remove_column :orders, :express_order_id
    remove_column :orders, :express_at
  end
end
