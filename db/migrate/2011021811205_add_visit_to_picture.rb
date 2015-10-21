class AddVisitToPicture < ActiveRecord::Migration
  def self.up
    add_column :pictures, :visits, :integer, :default=>0
  end

  def self.down
    remove_column :pictures, :visits
  end
end
