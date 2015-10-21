class CreateProvinces < ActiveRecord::Migration
  def self.up
    create_table :provinces, :force => true do |t|
      t.string :name,:limit=>20
      t.string :post_code,:limit=>20
      t.integer :users_count,:default=>0 
    end
    
    sql = ActiveRecord::Base.connection()
    sql.begin_db_transaction  
    File.open("./db/sql/provinces.sql") do |file|
      sql.update(file.readlines.to_s) 
    end
    sql.commit_db_transaction
    
  end

  def self.down
    drop_table :provinces
  end
end
