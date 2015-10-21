class AddNameToTaoProducts < ActiveRecord::Migration
  def self.up
  	add_column :tao_products, :name_, :string
  end

  def self.down
  end
end
