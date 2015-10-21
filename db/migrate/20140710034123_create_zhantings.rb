class CreateZhantings < ActiveRecord::Migration
  def change
    create_table :zhantings do |t|
      t.integer :user_id
      t.integer :age_id
      t.integer :gandong_count, :default=>0
      t.integer :post_count, :default=>0
      t.timestamps
    end
  end
end
