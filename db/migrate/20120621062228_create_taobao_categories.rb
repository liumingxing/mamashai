class CreateTaobaoCategories < ActiveRecord::Migration
  def self.up
    create_table :taobao_categories do |t|
      t.string :code, :limit=>100
      t.string :name, :limit=>100
      t.integer :parent_id
      t.string  :parent_code, :limit=>100
      t.string :taobao_name, :limit=>100
      t.string :age, :limit=>100
      t.boolean :is_parent, :default=>false
      t.timestamps
    end
    
    add_index :taobao_categories, :code, :unique=>true
    
    TaobaoCategory.create(:name=>"奶粉/辅食/营养品", :taobao_name=>"奶粉/辅食/营养品", :code=>35, :is_parent=>true)
    TaobaoCategory.create(:name=>"童装/童鞋/亲子装", :taobao_name=>"童装/童鞋/亲子装", :code=>50008165, :is_parent=>true)
    TaobaoCategory.create(:name=>"尿片/洗护/喂哺/推车床", :taobao_name=>"尿片/洗护/喂哺/推车床", :code=>50014812, :is_parent=>true)
    TaobaoCategory.create(:name=>"玩具/模型/动漫/早教/益智", :taobao_name=>"玩具/模型/动漫/早教/益智", :code=>25, :is_parent=>true)
    TaobaoCategory.create(:name=>"孕妇装/孕产妇用品/营养", :taobao_name=>"孕妇装/孕产妇用品/营养", :code=>50022517, :is_parent=>true)
  end

  def self.down
    drop_table :taobao_categories
  end
end
