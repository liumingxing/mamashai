class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.string :sid #随机编码
      t.integer :user_id
      t.string :state #状态
      t.decimal :money,:precision=>8,:scale=>2,:defalut=>0 #金额
      t.datetime :limit_time #使用期限
      t.integer :tp,:default=>0 #类型
      t.integer :score,:default=>0 #需要积分
      t.timestamps
    end
    
    add_column :orders, :receiver_name, :string
    add_column :orders, :receiver_address, :string
    add_column :orders, :receiver_mobile, :string
    add_column :orders,:coupon_id,:integer
    add_column :order_addresses,:memo,:text
  end

  def self.down
    remove_column :order_addresses, :memo
    remove_column :orders, :coupon_id
    remove_column :orders, :receiver_mobile
    remove_column :orders, :receiver_address
    remove_column :orders, :receiver_name
    drop_table :coupons
  end
end
