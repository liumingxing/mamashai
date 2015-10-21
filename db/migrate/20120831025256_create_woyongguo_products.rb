class CreateWoyongguoProducts < ActiveRecord::Migration
  def self.up
    create_table :woyongguo_products do |t|
      t.integer :woyongguo_id
      t.integer :taobao_product_id
      t.timestamps
    end
  end

  def self.down
    drop_table :woyongguo_products
  end
end
