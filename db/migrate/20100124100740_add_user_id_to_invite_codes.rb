class AddUserIdToInviteCodes < ActiveRecord::Migration
  def self.up
    add_column :invite_codes, :user_id, :integer
    add_column :users, :invite_codes_count, :integer,:default=>0
  end

  def self.down
  end
end
