class CreateVideoResources < ActiveRecord::Migration
  def change
    create_table :video_resources do |t|
      t.string :name
      t.integer :video_category_id
      t.string :logo
      t.string :url
      t.string :desc
      t.timestamps
    end
  end
end
