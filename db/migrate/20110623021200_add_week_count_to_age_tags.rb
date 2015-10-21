class AddWeekCountToAgeTags < ActiveRecord::Migration
  def self.up
    add_column :age_tags, :week_count, :integer, :default => 0
  end

  def self.down
    remove_column :age_tags, :week_count
  end
end
