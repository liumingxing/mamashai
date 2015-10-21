class CreateKeywordSignups < ActiveRecord::Migration
  def self.up
    create_table :keyword_signups, :force => true do |t|
      t.string :name,:limit=>50
      t.integer :hits_count,:default=>0
      t.integer :signups_count,:default=>0
    end
  end
  
  def self.down
    drop_table :keyword_signups
  end
end
