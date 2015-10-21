class AddSignupedUserIdToInviteCodes < ActiveRecord::Migration
  def self.up
    add_column :invite_codes, :signuped_user_id, :integer
  end

  def self.down
  end
end
