class AddEventsCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users,:ask_count,:integer,:default=>0
    add_column :users,:events_count,:integer,:default=>0
    add_column :users,:info_count,:integer,:default=>0
    add_column :users,:spots_count,:integer,:default=>0
  end

  def self.down
    remove_column :users,:ask_count
    remove_column :users,:events_count
    remove_column :users,:info_count
    remove_column :users,:spots_count
  end
end
