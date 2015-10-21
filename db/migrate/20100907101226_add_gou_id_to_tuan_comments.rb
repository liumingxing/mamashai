class AddGouIdToTuanComments < ActiveRecord::Migration
  def self.up
    remove_column :tuan_comments, :eproduct_id
    remove_column :tuans, :eproduct_category_id
    add_column :tuan_comments, :gou_id, :integer
    add_column :tuans, :gou_category_id, :integer
  end

  def self.down
    add_column :tuan_comments, :eproduct_id
    add_column :tuans, :eproduct_category_id
    remove_column :tuan_comments, :gou_id
    remove_column :tuans, :gou_category_id, :integer
  end
end
