class CreateProducts < ActiveRecord::Migration
  def self.up
    drop_table :products
    create_table :products do |t|
      t.string :name
      t.string :code
      t.string :state
      t.float :price
      t.float :discount ,:default=>1
      t.text :desc
      t.text :desc_history
      t.string :intro
      t.text :intro_history
      t.string :thumb
      t.integer :category_id
      t.boolean :has_attachment
      t.string :cond

      t.timestamps
    end
    add_index :products, :name, :unique => true 
    add_index :products, :code, :unique => true 
    
    sql = ActiveRecord::Base.connection()
    sql.begin_db_transaction  
    File.open("./db/sql/products.sql") do |file|
      sql.update(file.readlines.to_s) 
    end
    sql.commit_db_transaction
    
  end

  def self.down
    drop_table :products
  end
end
