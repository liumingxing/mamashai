class AddPreferentialToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :preferential, :float
  end

  def self.down
    remove_column :products, :preferential
  end
end
