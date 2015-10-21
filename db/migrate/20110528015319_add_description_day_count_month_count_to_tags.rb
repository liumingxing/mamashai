class AddDescriptionDayCountMonthCountToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :description, :string
    add_column :tags, :month_count, :integer, :default => 0
    add_column :tags, :day_count, :integer, :default => 0
  end

  def self.down
    remove_column :tags, :description, :month_count, :day_count
  end
end
