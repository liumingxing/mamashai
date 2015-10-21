class CreateAOrders < ActiveRecord::Migration
  def change
    create_table :a_orders do |t|
      t.integer :user_id
      t.float :price
      t.float :o_price 
      t.integer :score_amount			#使用晒豆抵扣金额
      t.integer :redpacket_amount		#使用红包抵扣金额
      t.integer :red_packet_id			#红包id
      t.float :payment			#真实付款额
      t.string :paymethods		#付款方式
      t.string :status#, :default=>"待付款"
      t.string :address
      t.string :receiver
      t.string :mobile
      t.string :post_code
      t.string :province
      t.string :city
      t.timestamps
    end
  end
end
