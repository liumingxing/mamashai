class AddBrandItemToGouCategories < ActiveRecord::Migration
  def self.up
    add_column :gou_categories, :brand_item, :string
  end

  def self.down
    remove_column :gou_categories, :brand_item
  end
end
