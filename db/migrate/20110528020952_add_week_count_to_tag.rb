class AddWeekCountToTag < ActiveRecord::Migration
  def self.up
    add_column :tags, :week_count, :integer, :default => 0
  end

  def self.down
    remove_column :tags, :week_count
  end
end
