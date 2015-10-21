class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string :state
      t.integer :lock_version
      t.text :info
      t.float :total_money
      t.float :fright_money
      t.float :total_item_money
      t.float :favorable_money
      t.string :payment_info

      t.timestamps
    end
    
  end

  def self.down
    drop_table :orders
  end
end
