class AddRecommandToTaoCategories < ActiveRecord::Migration
  def self.up
  	add_column :tao_categories, :recommand, :boolean, :default=>false, :null=>false
  end

  def self.down
  end
end
