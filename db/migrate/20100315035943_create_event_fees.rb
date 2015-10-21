class CreateEventFees < ActiveRecord::Migration
  def self.up
    create_table :event_fees do |t|
      t.float :total_fee1,:default=>0
      t.float :total_fee2,:default=>0
      t.float :total_fee3,:default=>0
      t.string :fee_remark,:limit=>1000
      t.boolean :is_unopen,:boolean,:default=>false
      t.integer :event_id
      t.datetime :created_at
    end
    add_index :event_fees,:event_id
  end
  
  def self.down
    drop_table :event_fees
  end
end
