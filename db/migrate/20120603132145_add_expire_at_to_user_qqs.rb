class AddExpireAtToUserQqs < ActiveRecord::Migration
  def self.up
    add_column :user_qqs, :expire_at, :integer
  end

  def self.down
  end
end
