class AddStateToGous < ActiveRecord::Migration
  def self.up
    add_column :gous, :state, :string, :default => "unpublish"
    add_column :gou_categories, :state, :string, :default => "unpublish"
    add_column :gou_brands, :state, :string, :default => "unpublish"
    add_column :gou_sites, :state, :string, :default => "unpublish"
  end

  def self.down
    remove_column :gous, :state
    remove_column :gou_categories, :state
    remove_column :gou_brands, :state
    remove_column :gou_sites, :state
  end
end
