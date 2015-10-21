class CreateLevelScoreLogs < ActiveRecord::Migration
  def change
    create_table :level_score_logs do |t|
      t.integer :user_id
      t.integer :score
      t.string :desc
      t.timestamps
    end
  end
end
