class AddEventIdToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :event_id, :integer
    add_column :posts, :rate, :float, :default=> 0 
  end
  
  def self.down
  end
end
