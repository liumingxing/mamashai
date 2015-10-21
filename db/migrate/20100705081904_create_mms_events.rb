class CreateMmsEvents < ActiveRecord::Migration
  def self.up
    create_table :mms_events do |t|
      t.string :url, :limit=>255
      t.string :name, :limit=>255
      t.string :image_url, :limit=>255
      t.integer :state, :default=>0, :limit=>1 #活动状态，默认0-未进行，1-进行中，2-已结束
      t.datetime :begin_time
      t.datetime :end_time
      t.timestamps
    end
  end

  def self.down
    drop_table :mms_events
  end
end
