class CreateUserOrders < ActiveRecord::Migration
  def self.up
    create_table :user_orders, :force => true do |t|
      t.string :order_no,:limit=>20
      t.string :order_tp,:limit=>15
      t.string :owner_name,:limit=>20
      t.string :owner_mobile,:limit=>20
      t.string :address,:limit=>80
      t.string :post_code,:limit=>10
      t.string :contact_name,:limit=>20
      t.string :contact_mobile,:limit=>20
      t.string :contact_email,:limit=>35
      t.string :contact_tel,:limit=>20
      t.string :contact_tel_pre,:limit=>5
      t.string :contact_tel_post,:limit=>5
      t.string :contact_fax,:limit=>20
      t.string :note,:limit=>500
      t.boolean :is_confirm,:default=>false
      t.integer :province_id
      t.integer :city_id
      t.datetime :created_at
    end
    
    add_index :user_orders, :order_no
       
  end
  
  
  
  def self.down
    drop_table :user_orders
  end
end
