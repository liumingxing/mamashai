class AddUserNameToScoreEvents < ActiveRecord::Migration
  def self.up
    add_column :score_events, :user_name, :string
  end

  def self.down
  end
end
