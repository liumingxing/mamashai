class AddHideToDdhs < ActiveRecord::Migration
  def self.up
  	add_column :ddhs, :hide, :boolean
  end

  def self.down
  end
end
