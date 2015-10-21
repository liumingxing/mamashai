class CreateGouCategories < ActiveRecord::Migration
  def self.up
    create_table :gou_categories do |t|
      t.string  :name
      t.integer :gous_count, :default => 0
      t.integer :tuans_count, :default => 0
      t.text    :label
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :scope_id
      t.timestamps
    end
  end

  def self.down
    drop_table :gou_categories
  end
end