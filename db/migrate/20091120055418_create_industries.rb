class CreateIndustries < ActiveRecord::Migration
  def self.up
    create_table :industries, :force => true do |t|
      t.string :name,:limit=>40
      t.integer :users_count,:default=>0
    end
    
      
    sql = ActiveRecord::Base.connection()
    sql.begin_db_transaction  
    File.open("./db/sql/industries.sql") do |file|
      while line = file.gets 
        sql.update(line) 
      end
    end
    sql.commit_db_transaction
    
  end
  
  def self.down
    drop_table :industries
  end
end
