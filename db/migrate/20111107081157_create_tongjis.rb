class CreateTongjis < ActiveRecord::Migration
  def self.up
    create_table :tongjis do |t|
      t.string :url, :limit=>100
      t.string :ip,  :limit=>20
      t.string :refer, :limit=>150
      t.string :agent, :limit=>100
      t.integer :count, :default=>1
      t.timestamps
    end
  end

  def self.down
    drop_table :tongjis
  end
end
