class CreateMmsAwardUsers < ActiveRecord::Migration
  def self.up
    create_table :mms_award_users do |t|
      t.integer :mms_event_id
      t.integer :user_id
      t.date :award_date
      t.integer :award_type
      t.index :mms_event_id
      t.index :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mms_award_users
  end
end
