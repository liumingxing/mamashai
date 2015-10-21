class CreateTongjiDays < ActiveRecord::Migration
  def change
    create_table :tongji_days do |t|
      t.date :day
      t.integer :a1
      t.integer :a2
      t.integer :a3
      t.integer :a4
      t.integer :a5
      t.integer :a6
      t.integer :a7
      t.integer :a8
      t.integer :a9
      t.integer :a10
      t.integer :a11
      t.integer :a12
      t.integer :a13
      t.integer :a14
      t.integer :a15
      t.timestamps
    end
  end
end
