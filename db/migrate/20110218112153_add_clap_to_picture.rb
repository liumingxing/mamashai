class AddClapToPicture < ActiveRecord::Migration
  def self.up
    add_column :pictures, :claps, :integer, :default=>0
  end

  def self.down
    remove_column :pictures, :claps
  end
end
