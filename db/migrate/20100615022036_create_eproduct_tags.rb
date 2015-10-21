class CreateEproductTags < ActiveRecord::Migration
  def self.up
    create_table :eproduct_tags do |t|
      t.string :name,:limit=>100
      t.integer :eproducts_count,:default=>0
      t.integer :eproduct_category_id
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :eproduct_tags
  end
end
