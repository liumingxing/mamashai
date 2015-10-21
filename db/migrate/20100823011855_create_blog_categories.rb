class CreateBlogCategories < ActiveRecord::Migration
  def self.up
    create_table :blog_categories do |t|
      t.string :name
      t.references :user

      t.timestamps
    end
    add_column :posts, :blog_category_id, :integer
  end

  def self.down
    drop_table :blog_categories
    remove_column :posts, :blog_category_id
  end
end
