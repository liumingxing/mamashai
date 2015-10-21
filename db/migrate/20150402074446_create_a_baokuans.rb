class CreateABaokuans < ActiveRecord::Migration
  def change
    create_table :a_baokuans do |t|
      t.integer :a_product_id
      t.datetime :begin_at 
      t.datetime :stop_at
      t.timestamps
    end
  end
end
