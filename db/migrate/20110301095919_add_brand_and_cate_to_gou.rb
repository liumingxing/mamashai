class AddBrandAndCateToGou < ActiveRecord::Migration
  def self.up
    add_column :gous, :brand, :string, :limit=>50
    add_column :gous, :cate, :string, :limit=>50
    add_column :gous, :site_id, :integer
  end

  def self.down
  end
end
