class CreateGouBrands < ActiveRecord::Migration
  def self.up
    create_table :gou_brands do |t|
      t.string  :name   # => 中文名称
      t.string  :logo
      t.string  :e_name  # => 英文名称
      t.string  :cradle  # => 发源地
      t.string  :link 
      t.integer :gous_count, :default => 0
      t.integer :tuan_comments_count, :default => 0
      t.integer :hit_count, :default => 0 # => 访问数
      t.integer :value_1
      t.integer :value_2
      t.integer :value_3
      t.integer :value_4
      t.integer :value_5
      t.integer :rate
      t.integer :rates_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :gou_brands
  end
end
