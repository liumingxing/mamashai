class AddOnlyToCalendarAdvs < ActiveRecord::Migration
  def self.up
  	add_column :calendar_advs, :only, :string, :length=>40
  end

  def self.down
  end
end
