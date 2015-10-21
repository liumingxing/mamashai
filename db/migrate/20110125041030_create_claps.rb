class CreateClaps < ActiveRecord::Migration
  def self.up
    create_table :claps do |t|
      t.integer :user_id
      t.integer :tp_id
      t.string :tp, :limit=>100
      t.datetime :created_at
    end
    add_index :claps, :tp_id
  end

  def self.down
    drop_table :claps
  end
end
