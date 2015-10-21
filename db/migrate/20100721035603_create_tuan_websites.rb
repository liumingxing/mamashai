class CreateTuanWebsites < ActiveRecord::Migration
  def self.up
    create_table :tuan_websites do |t|
      t.string :name,:limit=>100
      t.string :url,:limit=>150
      t.integer :tuans_count, :default=>0
      t.datetime :open_at
      t.integer :average_hot_count, :default=>0
      t.integer :average_rate, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :tuan_websites
  end
end
