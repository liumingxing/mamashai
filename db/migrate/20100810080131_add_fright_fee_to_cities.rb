class AddFrightFeeToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :fright_fee, :float,:default=>10.0
    add_column :tuans, :max_amount,:integer
  end

  def self.down
    remove_column :tuans, :max_amount
    remove_column :cities, :fright_fee
  end
end
