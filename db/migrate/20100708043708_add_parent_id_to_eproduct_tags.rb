class AddParentIdToEproductTags < ActiveRecord::Migration
  def self.up
    add_column :eproduct_tags, :parent_id, :integer
  end

  def self.down
    remove_column :eproduct_tags, :parent_id
  end
end
