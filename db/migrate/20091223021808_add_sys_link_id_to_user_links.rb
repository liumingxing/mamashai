class AddSysLinkIdToUserLinks < ActiveRecord::Migration
  def self.up
    add_column :user_links, :sys_link_id, :integer
  end

  def self.down
  end
end
