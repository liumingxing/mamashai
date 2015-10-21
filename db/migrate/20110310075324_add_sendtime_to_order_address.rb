class AddSendtimeToOrderAddress < ActiveRecord::Migration
  def self.up
    add_column :order_addresses, :send_time, :string, :limit=>100
  end

  def self.down
    remove_column :order_addresses, :send_time
  end
end
