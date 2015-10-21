class AddLogoToTaoCategories < ActiveRecord::Migration
  def self.up
    add_column :tao_categories, :logo_product, :integer
  end

  def self.down
  end
end
