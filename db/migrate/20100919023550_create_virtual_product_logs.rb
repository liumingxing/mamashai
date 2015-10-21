class CreateVirtualProductLogs < ActiveRecord::Migration
  def self.up
    create_table :virtual_product_logs do |t|
      t.string :code
      t.string :password
      t.integer :user_id
      t.integer :operator_id
      t.integer :virtual_product_id
      t.integer :order_item_id
      t.datetime :end_time
      t.datetime :begin_time
      t.timestamps
    end
  end

  def self.down
    drop_table :virtual_product_logs
  end
end
