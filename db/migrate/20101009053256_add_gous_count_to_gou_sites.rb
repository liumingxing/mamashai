class AddGousCountToGouSites < ActiveRecord::Migration
  def self.up
    add_column :gou_sites, :gous_count, :integer, :default => 0
  end

  def self.down
    remove_column :gou_sites, :gous_count
  end
end
