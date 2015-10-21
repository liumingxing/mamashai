class AddHideToWeekTag < ActiveRecord::Migration
  def self.up
  	add_column :week_tags, :hide, :boolean, :null=>true, :default=>false
  end

  def self.down
  end
end
