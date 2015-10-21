class CreateBbrlStars < ActiveRecord::Migration
  def change
    create_table :bbrl_stars do |t|
      t.string :tp, :length=>10, :null=>false
      t.integer :user_id, :null=>false
      t.integer :num, :null=>false				#期数
      t.timestamps
    end
  end
end
