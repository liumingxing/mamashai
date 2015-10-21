class CreateBalanceLogs < ActiveRecord::Migration
  def self.up
    create_table :balance_logs do |t|
      t.integer :user_id 
      t.string :log #详情
      t.string :payment #收支
      t.float :cash, :default=>0.0 #交易金额
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :balance_logs
  end
end
