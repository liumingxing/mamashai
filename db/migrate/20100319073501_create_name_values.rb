class CreateNameValues < ActiveRecord::Migration
  def self.up
    create_table :name_values, :force => true do |t|
      t.string :name,:limit=>500
      t.text :value
    end
    
    sql = ActiveRecord::Base.connection()
    sql.begin_db_transaction  
    File.open("./db/sql/name_values.sql") do |file|
      while line = file.gets 
        sql.update(line) 
      end
    end
    sql.commit_db_transaction
    
  end
  
  def self.down
    drop_table :name_values
  end
end
