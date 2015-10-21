class CreateBaomings < ActiveRecord::Migration
  def self.up
    create_table :baomings do |t|
      t.string :name
      t.timestamps
    end

    add_index :baomings, :name, :unique=>true
  end

  def self.down
    drop_table :baomings
  end
end
