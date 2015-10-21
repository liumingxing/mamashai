class AddItemIdToOrderItems < ActiveRecord::Migration
  def self.up
    add_column :order_items, :item_id, :integer
    add_column :order_items, :item_type, :string
  end

  def self.down
    remove_column :order_items, :item_id
    remove_column :order_items, :item_type
  end
end
