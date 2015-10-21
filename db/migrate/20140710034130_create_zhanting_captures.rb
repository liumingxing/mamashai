class CreateZhantingCaptures < ActiveRecord::Migration
  def change
    create_table :zhanting_captures do |t|
      t.integer :user_id
      t.string :logo
      t.timestamps
    end
  end
end
