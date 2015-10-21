class AddNoteToOrderLogs < ActiveRecord::Migration
  def self.up
    add_column :order_logs, :note, :string
  end

  def self.down
    remove_column :order_logs, :note
  end
end
