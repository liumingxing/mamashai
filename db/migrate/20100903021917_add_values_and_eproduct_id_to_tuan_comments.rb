class AddValuesAndEproductIdToTuanComments < ActiveRecord::Migration
  def self.up
    add_column :tuan_comments, :value_1, :integer
    add_column :tuan_comments, :value_2, :integer
    add_column :tuan_comments, :value_3, :integer
    add_column :tuan_comments, :value_4, :integer
    add_column :tuan_comments, :value_5, :integer
    add_column :tuan_comments, :eproduct_id, :integer
  end

  def self.down
    remove_column :tuan_comments, :value_1
    remove_column :tuan_comments, :value_2
    remove_column :tuan_comments, :value_3
    remove_column :tuan_comments, :value_4
    remove_column :tuan_comments, :value_5
    remove_column :tuan_comments, :eproduct_id
  end
end
