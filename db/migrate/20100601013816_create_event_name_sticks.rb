class CreateEventNameSticks < ActiveRecord::Migration
  def self.up
    create_table :event_name_sticks do |t|
      t.string :kid_name,:limit=>50
      t.string :gender,:limit=>10
      t.date :birthday
      t.string :father
      t.string :mother
      t.string :mobile
      t.string :address
      t.string :post
      t.integer :user_id
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :event_name_sticks
  end
end
