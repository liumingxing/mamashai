class CreateTaoYouhuiCategories < ActiveRecord::Migration
  def self.up
    create_table :tao_youhui_categories do |t|
      t.string :name
      t.string :code
      t.timestamps
    end
  end

  def self.down
    drop_table :tao_youhui_categories
  end 
end
