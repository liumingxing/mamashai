class AddInviteUserIdToUserSignups < ActiveRecord::Migration
  def self.up
    add_column :user_signups, :invite_user_id, :integer
  end
  
  def self.down
    remove_column :user_signups, :invite_user_id
  end
end
