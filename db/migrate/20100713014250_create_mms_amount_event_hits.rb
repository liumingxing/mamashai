class CreateMmsAmountEventHits < ActiveRecord::Migration
  def self.up
    create_table :mms_amount_event_hits do |t|
      t.string :event_name
      t.string :url
      t.string :image_url
      t.datetime :begin_time
      t.datetime :end_time
      t.integer :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :mms_amount_event_hits
  end
end
