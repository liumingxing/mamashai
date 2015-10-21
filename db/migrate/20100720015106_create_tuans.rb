class CreateTuans < ActiveRecord::Migration
  def self.up
    create_table :tuans do |t|
      t.integer :tuan_website_id
      t.integer :tuan_category_id
      t.string :address,:limit=>250 #地址
      t.string :url,:limit=>250 #地址
      t.string :logo,:limit=>100 #团购图片
      t.datetime :begin_time #开始时间
      t.datetime :end_time #结束时间
      t.integer :person_amount #团购人数
      t.text :content #团购内容说明
      t.string :title,:limit=>200 #团购主题
      t.float :origin_price #原价
      t.float :current_price #现价
      t.float :discount #折扣
      t.float :save_money #节省
      t.integer :hits_count,:default=>0 #点击次数
      t.integer :buyers_count,:default=>0 #购买人数
      t.integer :tuan_comments_count,:default=>0 #评论数
      t.integer :province_id #省份id
      t.integer :city_id #城市id
      t.integer :rate, :default=>0 #评分
      t.integer :rates_count, :default=>0
      t.integer :favorite_tuans_count, :default=>0
      t.integer :forward_posts_count, :default=>0
      t.index :tuan_category_id
      t.index :tuan_website_id
      t.timestamps
    end
  end

  def self.down
    drop_table :tuans
  end
end
