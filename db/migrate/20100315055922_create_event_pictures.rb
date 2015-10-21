class CreateEventPictures < ActiveRecord::Migration
  def self.up
    create_table :event_pictures do |t|
      t.string :logo,:limit=>50
      t.integer :event_id
      t.integer :user_id
      t.datetime :created_at
    end
    add_index :event_pictures,:event_id
  end

  def self.down
    drop_table :event_pictures
  end
end
