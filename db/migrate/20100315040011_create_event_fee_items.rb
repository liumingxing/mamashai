class CreateEventFeeItems < ActiveRecord::Migration
  def self.up
    create_table :event_fee_items do |t|
      t.string :name
      t.float :fee1,:default=>0
      t.float :fee2,:default=>0
      t.float :fee3,:default=>0
      t.integer :event_fee_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :event_fee_items
  end
end
