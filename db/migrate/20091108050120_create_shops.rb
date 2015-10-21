class CreateShops < ActiveRecord::Migration
  def self.up
    create_table :shops, :force => true do |t|
      t.string :name,:limit=>100
      t.string :url,:limit=>200
      t.string :logo,:limit=>50
      t.string :description,:limit=>50
      t.string :content,:limit=>500
      t.string :discount_policy,:limit=>500
      t.string :deliver_policy,:limit=>50
      t.string :note,:limit=>500
      t.float :discount
      t.integer :shop_products_count,:default=>0 
      t.integer :view_count,:default=>0
      t.integer :posts_count,:default=>0 
      t.datetime :created_at
    end
    
    add_index :shops, :shop_products_count
    add_index :shops, :posts_count
    
    
  end
  
  
  
  def self.down
    drop_table :shops
  end
end
