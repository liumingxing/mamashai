class CreateEproducts < ActiveRecord::Migration
  def self.up
    create_table :eproducts do |t|
      t.string :name,:limit=>100
      t.text :content
      t.string :logo,:limit=>100
      t.string :site_name,:limit=>200
      t.string :link,:limit=>200
      t.integer :click_count,:default=>0
      t.integer :user_id
      t.integer :post_id
      t.integer :tp
      t.integer :eproduct_category_id
      t.integer :eproduct_tag_id
      
      t.timestamps
    end
    add_column :users, :eproducts_count, :integer, :default=>0
    add_column :posts, :eproduct_id, :integer
  end
  
  def self.down
    drop_table :eproducts
    remove_column :users, :eproducts_count
    remove_column :posts, :eproduct_id
  end
end
