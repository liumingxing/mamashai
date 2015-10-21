class AddTpToOrderLog < ActiveRecord::Migration
  def self.up
    add_column :order_logs, :tp, :integer,:default=>0
  end

  def self.down
    remove_column :order_logs, :tp
  end
end
