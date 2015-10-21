class CreateOrderAddresses < ActiveRecord::Migration
  def self.up
    create_table :order_addresses do |t|
      t.string :name
      t.string :address
      t.integer :province_id
      t.integer :city_id
      t.string :post_code
      t.string :phone
      t.string :mobile
      t.string :email
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :order_addresses
  end
end
