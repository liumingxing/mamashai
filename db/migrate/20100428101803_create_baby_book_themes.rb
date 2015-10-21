class CreateBabyBookThemes < ActiveRecord::Migration
  def self.up
    create_table :baby_book_themes do |t|
      t.string :name,:limit=>20
      t.string :description,:limit=>200
      t.integer :tp
      t.integer :layout_tp,:default=>1
      t.datetime :created_at
    end
    sql = ActiveRecord::Base.connection()
    sql.begin_db_transaction  
    File.open("./db/sql/baby_book_themes.sql") do |file|
      sql.update(file.readlines.to_s) 
    end
    sql.commit_db_transaction
  end
  
  def self.down
    drop_table :baby_book_themes
  end
end
