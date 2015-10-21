class CreateEventUsers < ActiveRecord::Migration
  def self.up
    create_table :event_users, :force => true do |t|
      t.integer :event_id
      t.integer :user_id
      t.integer :tp,:default=>0
      t.integer :join_num
      t.string :mobile,:limit=>20
      t.string :email,:limit=>30
      t.string :remark,:limit=>150
      t.string :note,:limit=>150
      t.datetime :created_at
    end
    add_index :event_users, :event_id
    add_index :event_users, :user_id
  end
  
  def self.down
  end
end
