class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.string :name,:limit=>150
      t.string :content,:limit=>1500
      t.string :logo,:limit=>150
      t.integer :posts_count,:default=>0
      t.integer :subject_users_count,:default=>0 
      t.integer :tp,:default=>0
      t.boolean :is_good,:default=>false
      t.integer :user_id
      t.integer :subject_category_id
      t.timestamps
    end
    add_column :posts, :subject_id, :integer
  end

  def self.down
    drop_table :subjects
    remove_column :posts, :subject_id
  end
end
