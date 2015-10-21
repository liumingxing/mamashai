class CreateAOrderDetails < ActiveRecord::Migration
  def change
    create_table :a_order_details do |t|
      t.integer :a_order_id		#订单id
      t.integer :a_product_id   #商品id 
      t.float :price            #价格
      t.float :o_price          #原价
      t.integer :count			#数量
      t.float :sum				#总金额
      t.timestamps
    end
  end
end
