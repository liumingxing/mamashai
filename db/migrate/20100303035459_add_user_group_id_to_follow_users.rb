class AddUserGroupIdToFollowUsers < ActiveRecord::Migration
  def self.up
    add_column :follow_users, :follows_group_id, :integer
    add_column :follow_users, :fans_group_id, :integer
  end

  def self.down
    remove_column :follow_users, :follows_group_id
    remove_column :follow_users, :fans_group_id
  end
end
