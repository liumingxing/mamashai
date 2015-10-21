class AddPositionToTaoProducts < ActiveRecord::Migration
  def self.up
  	add_column :tao_products, :position, :integer
  end

  def self.down
  end
end
