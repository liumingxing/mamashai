class AddIsReadedToUserRewards < ActiveRecord::Migration
  def self.up
    add_column :user_rewards, :is_readed, :boolean, :default=>false
  end
  
  def self.down
    remove_column :user_rewards, :is_reader
  end
end
