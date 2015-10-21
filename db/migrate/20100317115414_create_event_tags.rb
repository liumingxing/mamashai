class CreateEventTags < ActiveRecord::Migration
  def self.up
    create_table :event_tags, :force => true do |t|
      t.string :name,:limit=>20
      t.integer :events_count,:default=>0
    end
    
    add_index :event_tags, :name
    
    sql = ActiveRecord::Base.connection()
    sql.begin_db_transaction  
    File.open("./db/sql/event_tags.sql") do |file|
      while line = file.gets 
        sql.update(line) 
      end
    end
    sql.commit_db_transaction
  end

  def self.down
  end
end
