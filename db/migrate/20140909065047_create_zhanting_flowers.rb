class CreateZhantingFlowers < ActiveRecord::Migration
  def change
    create_table :zhanting_flowers do |t|
	  t.integer :user_id
      t.integer :post_id
      t.timestamps
    end
  end
end
