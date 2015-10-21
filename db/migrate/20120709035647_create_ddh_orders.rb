class CreateDdhOrders < ActiveRecord::Migration
  def self.up
    create_table :ddh_orders do |t|
      t.integer :ddh_id
      t.integer :user_id
      t.string :name
      t.string :mobile
      t.string :address
      t.string :remark
      t.date :sent_at
      t.string :remark2
      t.timestamps
    end
  end

  def self.down
    drop_table :ddh_orders
  end
end
