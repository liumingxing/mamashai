class CreateScoreEvents < ActiveRecord::Migration
  def self.up
     create_table :score_events, :force => true do |t|
      t.string :event,:limit=>30
      t.integer :score
      t.integer :tag_id
      t.integer :user_id
      t.datetime :created_at
    end
    
    add_index :score_events, :user_id
    add_index :score_events, :tag_id
    
  end

  def self.down
  end
end
