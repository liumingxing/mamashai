class CreateTuanCategoryTemps < ActiveRecord::Migration
  def self.up
    create_table :tuan_category_temps do |t|
      t.string :name
      t.integer :tuan_category_id
      t.integer :tuans_count, :default=>0
      t.timestamps
    end
    
     add_column :tuans, :tuan_category_temp_id, :integer
  end

  def self.down
    drop_table :tuan_category_temps
    remove_column :tuans, :tuan_category_temp_id
  end
end
