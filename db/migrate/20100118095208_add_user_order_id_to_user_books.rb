class AddUserOrderIdToUserBooks < ActiveRecord::Migration
  def self.up
    add_column :user_books, :user_order_id, :integer
    remove_column :user_orders, :is_confirm
    add_column :user_orders, :status, :string
    add_column :user_orders, :user_id, :integer
    add_column :user_orders, :score, :integer
    add_column :user_orders, :money, :float
  end

  def self.down
  end
end
