class AddSupplierCodeToTuan < ActiveRecord::Migration
  def self.up
    add_column :tuans, :supplier_code,:string,:limit=>12
  end

  def self.down
    remove_column :tuans,:supplier_code
  end
end
