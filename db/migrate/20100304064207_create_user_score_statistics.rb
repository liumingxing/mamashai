class CreateUserScoreStatistics < ActiveRecord::Migration
  def self.up
    create_table :user_score_statistics do |t|
      t.integer :user_id
      t.integer :user_score_statistic_config_id
      t.integer :score

      t.timestamps
    end
    add_index :user_score_statistics,:user_id
    add_index :user_score_statistics, :user_score_statistic_config_id
    add_index :user_score_statistics,:score
  end

  def self.down
    drop_table :user_score_statistics
  end
end
