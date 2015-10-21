class AddMmsLevelToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :mms_level, :integer
  end

  def self.down
  end
end
