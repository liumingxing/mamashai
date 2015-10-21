class AddSaleCountToTuans < ActiveRecord::Migration
  def self.up
    add_column :tuans, :sale_count, :integer, :default=>0
  end

  def self.down
    remove_column :tuans, :sale_count
  end
end
