class AddInviteLimitNumToUsers < ActiveRecord::Migration

  def self.up
    add_column :users, :invite_limit_num, :integer ,:default=>5
    add_column :users, :is_hide_age, :boolean, :default=>false
    add_column :message_topics, :is_sys, :boolean ,:default=>false
    add_column :user_signups, :is_hide_age, :boolean, :default=>false
  end

  def self.down
  end

end
