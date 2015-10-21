class CreateUserSignups < ActiveRecord::Migration
  def self.up
    create_table :user_signups, :force => true do |t|
      t.string :email,:limit=>35
      t.string :password,:limit=>35
      t.string :password_reset,:limit=>35
      t.string :uuid,:limit=>50
      t.string :kid_gender1,:limit=>2
      t.string :kid_gender2,:limit=>2
      t.string :kid_gender3,:limit=>2
      t.datetime :kid_birthday1
      t.datetime :kid_birthday2
      t.datetime :kid_birthday3
      t.datetime :kid_birthday4
      t.integer :kids_count
      t.integer :user_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :user_signups
  end
end
