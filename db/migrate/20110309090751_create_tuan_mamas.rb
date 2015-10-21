class CreateTuanMamas < ActiveRecord::Migration
  def self.up
    create_table :tuan_mamas do |t|
      t.integer :tuan_id
      t.timestamps
    end
  end

  def self.down
    drop_table :tuan_mamas
  end
end
