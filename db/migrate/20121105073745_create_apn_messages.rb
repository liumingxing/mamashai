class CreateApnMessages < ActiveRecord::Migration
  def self.up
    create_table :apn_messages do |t|
      t.integer :user_id
      t.string :message
      t.timestamps
    end
  end

  def self.down
    drop_table :apn_messages
  end
end
