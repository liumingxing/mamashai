class AddIs100NoticeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_100_notice, :boolean, :default=>false
  end

  def self.down
  end
end
