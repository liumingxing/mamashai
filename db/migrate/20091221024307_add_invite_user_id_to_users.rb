class AddInviteUserIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :invite_user_id, :integer
  end

  def self.down
  end
end
