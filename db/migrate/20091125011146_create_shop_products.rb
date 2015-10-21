class CreateShopProducts < ActiveRecord::Migration
  def self.up
    create_table :shop_products, :force => true do |t|
      t.string :name,:limit=>100
      t.string :url,:limit=>200
      t.string :content,:limit=>300
      t.float :price
      t.float :money_back
      t.float :discount
      t.integer :shop_id
      t.integer :product_id
      t.datetime :created_at
    end
    
    add_index :shop_products, :shop_id
    add_index :shop_products, :product_id
    
  end
  
  def self.down
    drop_table :shop_products
  end
end
