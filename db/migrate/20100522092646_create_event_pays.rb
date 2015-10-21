class CreateEventPays < ActiveRecord::Migration
  def self.up
    create_table :event_pays do |t|
      t.integer :event_id
      t.integer :user_id
      t.float :pay_money,:default=>0
      t.integer :pay_users_count,:default=>1
      t.string :real_name,:limit=>20
      t.string :pay_names,:limit=>1000
      t.string :note,:limit=>1000
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :event_pays
  end
end
