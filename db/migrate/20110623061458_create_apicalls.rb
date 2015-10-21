class CreateApicalls < ActiveRecord::Migration
  def self.up
    create_table :apicalls do |t|
      t.string :name, :length=>100
      t.date   :occur
      t.integer :count, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :apicalls
  end
end
