class CreateBokergenVotes < ActiveRecord::Migration
  def change
    create_table :bokergen_votes do |t|
      t.string :name
      t.integer :vote_num
      t.string :status
      t.string :remark
      t.integer :user_id
      t.timestamps
    end
  end
end
