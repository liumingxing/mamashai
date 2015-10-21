class AddVisitToDdhs < ActiveRecord::Migration
  def self.up
  	add_column :ddhs, :visit, :integer, :default=>0
  end

  def self.down
  end
end
