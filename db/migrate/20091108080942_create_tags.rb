class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags, :force => true do |t|
      t.string :name,:limit=>20
      t.integer :posts_count,:default=>0 
      t.integer :category_id
    end
    
    add_index :tags, :name
    add_index :tags, :posts_count
    add_index :tags, :category_id
    
    sql = ActiveRecord::Base.connection()
    sql.begin_db_transaction  
    File.open("./db/sql/tags.sql") do |file|
      while line = file.gets 
        sql.update(line) 
      end
    end
    sql.commit_db_transaction
    
  end

  def self.down
     drop_table :tags
  end
end
