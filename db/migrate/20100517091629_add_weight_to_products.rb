class AddWeightToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :weight, :integer
  end

  def self.down
    remove_column :products, :weight
  end
end
