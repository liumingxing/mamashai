class CreateScoreActivities < ActiveRecord::Migration
  def change
    create_table :score_activities do |t|
      t.integer :user_id
      t.string :name

      t.timestamps
    end
  end
end
