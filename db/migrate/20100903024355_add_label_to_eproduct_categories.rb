class AddLabelToEproductCategories < ActiveRecord::Migration
  def self.up
    add_column :eproduct_categories, :label, :text
    add_column :eproduct_categories, :parent_id, :integer
    add_column :eproduct_categories, :lft, :integer
    add_column :eproduct_categories, :rgt, :integer
    add_column :eproduct_categories, :scope_id, :integer
    add_column :tuans, :eproduct_category_id, :integer
  end

  def self.down
    remove_column :tuans, :eproduct_category_id
    remove_column :eproduct_categories, :scope_id
    remove_column :eproduct_categories, :rgt
    remove_column :eproduct_categories, :lft
    remove_column :eproduct_categories, :parent_id
    remove_column :eproduct_categories, :label
  end
end
