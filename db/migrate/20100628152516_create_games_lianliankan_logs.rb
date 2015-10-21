class CreateGamesLianliankanLogs < ActiveRecord::Migration
  def self.up
    create_table :games_lianliankan_logs do |t|
      t.integer :games_lianliankan_id 
      t.integer :user_id
      t.time :cost_time

      t.timestamps
    end
  end

  def self.down
    drop_table :games_lianliankan_logs
  end
end
