class CreateBlacknames < ActiveRecord::Migration
  def self.up
    create_table :blacknames do |t|
      t.string :name
      t.string :ip
      t.timestamps
    end
    
    add_index :blacknames, :ip
  end

  def self.down
    drop_table :blacknames
  end
end
