class AddUnreadInvitedCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :unread_invited_count, :integer ,:default=>0
  end

  def self.down
  end
end
