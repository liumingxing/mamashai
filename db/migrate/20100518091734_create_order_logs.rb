class CreateOrderLogs < ActiveRecord::Migration
  def self.up
    create_table :order_logs do |t|
      t.integer :order_id
      t.integer :user_id
      t.string :log

      t.timestamps
    end
  end

  def self.down
    drop_table :order_logs
  end
end
