class AddEventTypeToEventNameSticks < ActiveRecord::Migration
  def self.up
    add_column :event_name_sticks, :event_type, :string
  end

  def self.down
    remove_column :event_name_sticks, :event_type
  end
end
