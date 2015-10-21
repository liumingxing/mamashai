class CreateGous < ActiveRecord::Migration
  def self.up
    create_table :gous do |t|
      t.string  :name, :limit=>100
      t.text    :content
      t.string  :logo, :limit=>100
      t.string  :site_name, :limit=>200
      t.string  :link, :limit=>200
      t.integer :click_count, :default=>0
      t.integer :tp
      t.decimal :price, :precision => 8, :scale => 2
      t.string  :standard
      t.string  :for_ages
      t.integer :value_1
      t.integer :value_2
      t.integer :value_3
      t.integer :value_4
      t.integer :value_5
      t.integer :rate
      t.integer :rates_count, :default => 0
      t.integer :tuan_comments_count, :default => 0
      t.integer :gou_category_id
      t.integer :gou_brand_id
      t.timestamps
    end
  end

  def self.down
    drop_table :gous
  end
end