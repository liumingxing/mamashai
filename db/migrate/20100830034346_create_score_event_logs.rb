class CreateScoreEventLogs < ActiveRecord::Migration
  def self.up
    create_table :score_event_logs do |t|
      t.references :score_event
      t.references :user
      t.string :log
      t.string :operator_name

      t.timestamps
    end
  end

  def self.down
    drop_table :score_event_logs
  end
end