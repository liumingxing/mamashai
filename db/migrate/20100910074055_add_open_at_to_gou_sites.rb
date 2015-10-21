class AddOpenAtToGouSites < ActiveRecord::Migration
  def self.up
    add_column :gou_sites, :open_at, :datetime
    add_column :gou_gou_sites, :url, :string
  end

  def self.down
    remove_column :gou_gou_sites, :url
    remove_column :gou_sites, :open_at
  end
end
