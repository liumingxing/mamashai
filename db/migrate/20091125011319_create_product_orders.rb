class CreateProductOrders < ActiveRecord::Migration
  def self.up
    create_table :product_orders, :force => true do |t|
      t.integer :shop_product_id
      t.integer :shop_id
      t.integer :product_id
      t.integer :user_id
      t.datetime :created_at
    end
    
    add_index :product_orders, :user_id
    
  end
  
  def self.down
    drop_table :product_orders
  end
end
