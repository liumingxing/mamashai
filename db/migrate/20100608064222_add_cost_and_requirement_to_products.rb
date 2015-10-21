class AddCostAndRequirementToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :cost, :float
    add_column :products, :requirement, :text
  end

  def self.down
    remove_column :products, :cost
    remove_column :products, :requirement
  end
end
