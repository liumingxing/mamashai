class CreateZhantingBabas < ActiveRecord::Migration
  def change
    create_table :zhanting_babas do |t|
      t.integer :user_id
      t.integer :post_id
      t.integer :age_id
      t.integer :flower_count, :default=>0
      t.timestamps
    end
  end
end
