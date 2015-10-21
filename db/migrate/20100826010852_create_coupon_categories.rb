class CreateCouponCategories < ActiveRecord::Migration
  def self.up
    create_table :coupon_categories do |t|
      t.string :logo
      t.string :name
      t.decimal :money,:precision=>8,:scale=>2,:default=>0 #面额
      t.integer :score,:null=>false  #积分
      t.integer :limit_time,:default=>(365*24*60*60) #有效期1年
      t.string :use
      t.integer :coupons_count, :default=>0
      t.string :log #显示到积分记录中去
      t.integer :position, :default=>0
      t.boolean :open, :default=>false
      t.integer :tp, :default=>0
      t.timestamps
    end
    
    add_column :coupons,:coupon_category_id,:integer
    Coupon.update_all("coupon_category_id=tp",["tp > ?",0])
    
  end

  def self.down
    remove_column :coupons,:coupon_category_id
    drop_table :coupon_categories
  end
end
