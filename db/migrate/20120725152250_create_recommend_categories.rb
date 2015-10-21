class CreateRecommendCategories < ActiveRecord::Migration
  def self.up
    create_table :recommend_categories do |t|
      t.integer :category_id   #类目ID
      t.integer :taobao_category_id #所属root类目
      t.string :position, :default => "index"       #位置
      
      t.timestamps
    end
  end

  def self.down
    drop_table :recommend_categories
  end
end
