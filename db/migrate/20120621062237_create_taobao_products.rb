class CreateTaobaoProducts < ActiveRecord::Migration
  def self.up
    create_table :taobao_products do |t|
      t.string :name
      t.string :pic_url
      t.string :location, :limit=>30
      t.string :category_id
      t.string :category_code
      t.string :iid, :limit=>30
      t.text :content
      t.float :price
      t.string :url
      t.string :url_mobile
      t.integer :click_count
      t.integer :like_count
      t.integer :comment_count
      t.integer :user_id
      t.string :shop_url
      t.float :commission                 #单件佣金
      t.integer :commission_num           #累计支出
      t.integer :volumn                  #月销量
      t.boolean :cancel
      t.timestamps
    end
    
    add_index :taobao_products, :url
    add_index :taobao_products, [:iid, :category_id], :unique=>true
    add_index :taobao_products, :iid
  end

  def self.down
    drop_table :taobao_products
  end
end
