class CreateGiftGets < ActiveRecord::Migration
  def self.up
    create_table :gift_gets, :force => true do |t|
      t.integer :gift_id
      t.integer :send_user_id
      t.integer :user_id
      t.boolean :is_no_name,:default=>false
      t.boolean :is_private,:default=>false
      t.boolean :is_send_hide,:default=>false
      t.boolean :is_get_hide,:default=>false
      t.string :content,:limit=>210
      t.datetime :created_at
    end
    
    add_index :gift_gets, :user_id
    
  end

  def self.down
    drop_table :gift_gets
  end
end
