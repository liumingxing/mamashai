class AddUserNameToOrderLogs < ActiveRecord::Migration
  def self.up
    add_column :order_logs, :user_name, :string
  end

  def self.down
    remove_column :order_logs, :user_name
  end
end
