class AddCodeToCalendarTipAdv < ActiveRecord::Migration
  def self.up
  	add_column :calendar_tip_advs, :text, :text
  end

  def self.down
  end
end
