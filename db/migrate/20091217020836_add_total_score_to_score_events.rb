class AddTotalScoreToScoreEvents < ActiveRecord::Migration
  def self.up
    add_column :score_events, :total_score, :integer
    add_column :user_profiles, :rand_code, :string, :limit=>10
  end

  def self.down
  end
end
