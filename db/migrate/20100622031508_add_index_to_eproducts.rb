class AddIndexToEproducts < ActiveRecord::Migration
  def self.up
    add_index :eproducts, :user_id
    add_index :eproducts, :post_id
    add_index :eproducts, :eproduct_tag_id
  end

  def self.down
    remove_index :eproducts, :user_id
    remove_index :eproducts, :post_id
    remove_index :eproducts, :eproduct_tag_id
  end
end
