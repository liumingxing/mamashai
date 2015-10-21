class AddOperatorIdToBalanceLogs < ActiveRecord::Migration
  def self.up
    add_column :balance_logs, :operator_id, :integer
  end

  def self.down
    remove_column :balance_logs, :operator_id
  end
end
