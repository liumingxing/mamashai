class AddStatusToEventPays < ActiveRecord::Migration
  def self.up
    add_column :event_pays, :status, :string, :limit=>20
    add_column :event_pays, :pay_user_ids, :string, :limit=>1000
    add_column :event_users, :is_pay, :boolean, :default=>false
    add_column :event_users, :city, :string,:limit=>30
  end
  
  def self.down
    remove_column :event_pays, :status 
    remove_column :event_pays, :pay_user_ids 
    remove_column :event_users, :is_pay
    remove_column :event_users, :city
  end
end
