class AlterScoreEvents < ActiveRecord::Migration
  def self.up
    rename_table('score_events', 'score_events_2010_08_20')
    create_table :score_events, :force => true do |t|
      t.string :event,:limit=>30
      t.integer :score
      t.integer :tag_id
      t.integer :user_id
      t.datetime :created_at
      t.integer :total_score
      t.integer :post_id
      t.string :user_name
      t.integer :operator_id
      t.integer :order_id
      t.integer :unit, :default => 1 
      t.string :event_description
      
      t.index :event
      t.index :user_id
      t.index :tag_id
    end
  end
  
  def self.down
    drop_table :score_events
    rename_table('score_events_2010_08_20', 'score_events')
  end
end
