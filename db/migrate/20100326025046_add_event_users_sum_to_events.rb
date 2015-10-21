class AddEventUsersSumToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :event_users_sum, :integer, :default=>0
  end
  
  def self.down
    remove_column :events, :event_users_sum
  end
end
