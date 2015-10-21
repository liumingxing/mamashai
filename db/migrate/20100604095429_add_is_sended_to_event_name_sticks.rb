class AddIsSendedToEventNameSticks < ActiveRecord::Migration
  def self.up
    add_column :event_name_sticks, :is_sended, :integer, :default=>0
  end

  def self.down
    remove_column :event_name_sticks, :is_sended
  end
end
