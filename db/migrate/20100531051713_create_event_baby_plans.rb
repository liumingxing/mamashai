class CreateEventBabyPlans < ActiveRecord::Migration
  def self.up
    create_table :event_baby_plans do |t|
      t.string :tags,:limit=>300
      t.string :tag,:limit=>50
      t.string :user_name,:limit=>50
      t.integer :user_id
      t.date :begin_at
      t.date :end_at
      t.datetime :start_at
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :event_baby_plans
  end
end
