class AddFansRemarkToFollowUsers < ActiveRecord::Migration
  def self.up
    add_column :follow_users, :fans_remark, :string, :limit=>50
  end

  def self.down
  end
end
