class CreateRecommendProducts < ActiveRecord::Migration
  def self.up
    create_table :recommend_products do |t|
      t.integer :taobao_product_id   #商品ID
      t.integer :taobao_category_id #所属类目
      t.string :position       #位置
      t.integer :queue, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :recommend_products
  end
end
