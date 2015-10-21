class AddBrandToTuanComments < ActiveRecord::Migration
  def self.up
    add_column :tuan_comments, :brand, :string, :limit=>20
    add_column :tuan_comments, :kind, :integer
    add_column :tuan_comments, :kind_id, :integer
    add_index :tuan_comments, [:kind_id, :kind]
  end

  def self.down
  end
end
