class AddWeekHotToAgeTag < ActiveRecord::Migration
  def self.up
  	add_column :age_tags, :week_hot, :boolean, :default=>false
  end

  def self.down
  end
end
