class CreateTuanCategories < ActiveRecord::Migration
  def self.up
    create_table :tuan_categories do |t|
      t.string :name
      t.integer :tuans_count, :default=>0

      t.timestamps
    end
  end

  def self.down
    drop_table :tuan_categories
  end
end
