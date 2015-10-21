class AddNickNameToFollowUsers < ActiveRecord::Migration
  def self.up
    add_column :follow_users, :nick_name, :string, :limit=>50
    add_column :follow_users, :fans_nick_name, :string, :limit=>50
  end

  def self.down
  end
end
