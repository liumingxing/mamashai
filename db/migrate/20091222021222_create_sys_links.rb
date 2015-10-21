class CreateSysLinks < ActiveRecord::Migration
  def self.up
    create_table :sys_links, :force => true do |t|
      t.string :name,:limit=>30
      t.string :url,:limit=>200
      t.integer :link_category_id
      t.integer :link_tag_id
      t.integer :order_num
    end
    
    add_index :sys_links, :order_num
    add_index :sys_links, :link_category_id
    add_index :sys_links, :link_tag_id
    
  end

  def self.down
  end
end
