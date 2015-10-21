class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities, :force => true do |t|
      t.string :name,:limit=>50
      t.string :post_code,:limit=>20
      t.integer :province_id
    end
    
    add_index :cities, :province_id
    
    sql = ActiveRecord::Base.connection()
    sql.begin_db_transaction  
    File.open("./db/sql/cities.sql") do |file|
      sql.update(file.readlines.to_s) 
    end
    sql.commit_db_transaction
    
  end
  
  def self.down
    drop_table :cities
  end
end
