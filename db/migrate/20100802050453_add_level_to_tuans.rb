class AddLevelToTuans < ActiveRecord::Migration
  def self.up
    add_column :tuans, :level, :integer, :default=>0
  end

  def self.down
    remove_column :tuans, :level
  end
end
