class CreateMmsAmountEventRefers < ActiveRecord::Migration
  def self.up
    create_table :mms_amount_event_refers do |t|
      t.references :mms_amount_event_hit
      t.string :link
      t.string :http_refer
      t.integer :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :mms_amount_event_refers
  end
end
