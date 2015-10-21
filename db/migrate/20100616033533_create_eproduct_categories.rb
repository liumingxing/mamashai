class CreateEproductCategories < ActiveRecord::Migration
  def self.up
    create_table :eproduct_categories do |t|
      t.string :name
      t.integer :eproducts_count

      t.timestamps
    end
  end

  def self.down
    drop_table :eproduct_categories
  end
end
