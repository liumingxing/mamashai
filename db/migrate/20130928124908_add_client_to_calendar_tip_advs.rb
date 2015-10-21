class AddClientToCalendarTipAdvs < ActiveRecord::Migration
  def self.up
  	add_column :calendar_tip_advs, :client, :string
  	add_column :calendar_advs, :client, :string
  end

  def self.down
  end
end
