class CreateVideoCategories < ActiveRecord::Migration
  def change
    create_table :video_categories do |t|
      t.string :name
      t.string :logo
      t.integer :parent_video_category
      t.integer :video_resources_count, :default=>0
      t.timestamps
    end
  end
end
