class AddInviteTuanUserIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :invite_tuan_user_id, :integer
  end

  def self.down
    remove_column :users, :invite_tuan_user_id
  end
end
