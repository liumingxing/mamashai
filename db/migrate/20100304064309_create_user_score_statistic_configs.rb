class CreateUserScoreStatisticConfigs < ActiveRecord::Migration
  def self.up
    create_table :user_score_statistic_configs do |t|
      t.string :name
      t.string :desc
      t.date :start_date
      t.date :end_date
      t.boolean :is_active

      t.timestamps
    end
  end

  def self.down
    drop_table :user_score_statistic_configs
  end
end
