class AddOrderNumToLinkTags < ActiveRecord::Migration
  def self.up
    add_column :link_tags, :order_num, :integer,:default=>0
  end

  def self.down
  end
end
