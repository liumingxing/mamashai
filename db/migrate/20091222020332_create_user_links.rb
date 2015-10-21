class CreateUserLinks < ActiveRecord::Migration
  def self.up
    create_table :user_links, :force => true do |t|
      t.string :name,:limit=>30
      t.string :url,:limit=>200
      t.integer :link_category_id
      t.integer :order_num
      t.integer :user_id
      t.datetime :created_at
    end
    
    add_index :user_links, :order_num
    add_index :user_links, :link_category_id
  end
  
  def self.down
  end
end
