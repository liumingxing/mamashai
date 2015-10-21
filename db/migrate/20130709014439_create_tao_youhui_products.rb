class CreateTaoYouhuiProducts < ActiveRecord::Migration
  def self.up
    create_table :tao_youhui_products do |t|
      t.string :name
      t.string :pic_url
      t.string :category_code
      t.string :iid
      t.float :o_price
      t.float :price
      t.string :url
      t.float :commission
      t.integer :commission_num
      t.integer :volumn
      t.string :youhui_code
      t.timestamps
    end
  end

  def self.down
    drop_table :tao_youhui_products
  end
end
