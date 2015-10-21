class AddValuesToTuans < ActiveRecord::Migration
  def self.up
    add_column :tuans, :value_1, :integer
    add_column :tuans, :value_2, :integer
    add_column :tuans, :value_3, :integer
    add_column :tuans, :value_4, :integer
    add_column :tuans, :value_5, :integer
  end

  def self.down
    remove_column :tuans, :value_1
    remove_column :tuans, :value_2
    remove_column :tuans, :value_3
    remove_column :tuans, :value_4
    remove_column :tuans, :value_5
  end
end
