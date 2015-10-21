class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.integer :product_id
      t.string :product_code
      t.string :product_name
      t.integer :product_state
      t.string :attachment
      t.integer :amount
      t.float :price
      t.float :order_price
      t.float :discount
      t.text :memo
      t.integer :order_id

      t.timestamps
    end
  end

  def self.down
    drop_table :order_items
  end
end
