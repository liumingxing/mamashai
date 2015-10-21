class AddSizeToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :size, :integer
  end

  def self.down
    remove_column :products, :size
  end
end
