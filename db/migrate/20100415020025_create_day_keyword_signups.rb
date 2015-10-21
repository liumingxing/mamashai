class CreateDayKeywordSignups < ActiveRecord::Migration
  def self.up
    create_table :day_keyword_signups, :force => true do |t|
      t.string :name,:limit=>50
      t.integer :signups_count,:default=>0
      t.integer :keyword_signup_id
      t.date :day
    end
  end
  
  def self.down
    drop_table :day_keyword_signups
  end
end
