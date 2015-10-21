class CreateScoreProfiles < ActiveRecord::Migration
  def self.up
    create_table :score_profiles do |t|
      t.string :event
      t.string :description
      t.integer :score,:default=>0
      t.timestamps
    end
    add_column :score_events, :operator_id, :integer
  end

  def self.down
    remove_column :score_events, :operator_id
    drop_table :score_profiles
  end
end
