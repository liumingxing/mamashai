class AddWaterPrintToPictureEditor < ActiveRecord::Migration
  def self.up
    add_column :picture_editors, :water_print, :boolean,  :default => false;
  end

  def self.down
    remove_column :picture_editors, :water_print
  end
end
