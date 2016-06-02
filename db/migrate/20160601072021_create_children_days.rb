class CreateChildrenDays < ActiveRecord::Migration
  def change
    create_table :children_days do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
