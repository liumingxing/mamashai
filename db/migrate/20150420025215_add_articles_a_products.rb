class AddArticlesAProducts < ActiveRecord::Migration
  def up
  	create_table :a_products_articles do |t|
      t.integer :article_id
      t.integer :a_product_id
      t.timestamps
    end
    add_index :a_products_articles, :article_id
    add_index :a_products_articles, :a_product_id
  end

  def down
  	drop_table :a_products_articles
  end
end
