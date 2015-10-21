class AddWapTpToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :wap_tp, :integer,:default=>0
  end

  def self.down
    remove_column :users, :wap_tp
  end
end
