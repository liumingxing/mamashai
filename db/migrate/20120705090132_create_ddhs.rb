class CreateDdhs < ActiveRecord::Migration
  def self.up
    create_table :ddhs do |t|
      t.string :logo
      t.integer :score
      t.float :price
      t.string :title
      t.string :content
      t.integer :count, :default=>0
      t.integer :remain, :default=>0
      t.date :begin_at
      t.date :end_at
      t.timestamps
    end
  end

  def self.down
    drop_table :ddhs
  end
end
