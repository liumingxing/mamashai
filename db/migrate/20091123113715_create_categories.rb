class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories, :force => true do |t|
      t.string :name,:limit=>20
      t.integer :posts_count,:default=>0
    end
    
    sql = ActiveRecord::Base.connection()
    sql.begin_db_transaction  
    File.open("./db/sql/categories.sql") do |file|
      while line = file.gets 
        sql.update(line) 
      end
    end
    sql.commit_db_transaction
  end

  def self.down
    drop_table :categories
  end
end
