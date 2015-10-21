class CreateTuanTemps < ActiveRecord::Migration
  def self.up
    create_table :tuan_temps do |t|
      t.integer :tuan_website_id,:limit=>250
      t.string :title
      t.string :url,:limit=>250
      t.string :logo,:limit=>150 #团购图片
      t.datetime :begin_time
      t.datetime :end_time
      t.integer :person_amount
      t.text :content
      t.float :origin_price
      t.float :current_price
      t.float :discount
      t.float :save_money
      t.string :tid
      t.string :address
      t.float :lng #经度
      t.float :lat #纬度
      t.boolean :passed, :default=>false

      t.timestamps
    end
  end

  def self.down
    drop_table :tuan_temps
  end
end
