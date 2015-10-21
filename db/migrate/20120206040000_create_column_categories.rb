class CreateColumnCategories < ActiveRecord::Migration
  def self.up
    create_table :column_categories do |t|
      t.string :name, :null=>false
      t.timestamps
    end
    
    ColumnCategory.create(:id=>1, :name=>"名家")
    ColumnCategory.create(:id=>2, :name=>"海外育儿")
    ColumnCategory.create(:id=>3, :name=>"职场妈妈")
    ColumnCategory.create(:id=>4, :name=>"超级奶爸")
    ColumnCategory.create(:id=>5, :name=>"艺术启蒙")
    ColumnCategory.create(:id=>6, :name=>"教育教养")
    ColumnCategory.create(:id=>7, :name=>"养护健康")
  end

  def self.down
    drop_table :column_categories
  end
end
