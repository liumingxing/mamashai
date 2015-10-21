class CreateMmsToolCategories < ActiveRecord::Migration
  def self.up
    create_table :mms_tool_categories do |t|
      t.string :name
      t.integer :position
      t.integer :mms_tools_count, :default=>0
      t.timestamps
    end
    add_column :mms_tools, :mms_tool_category_id, :integer
    add_column :mms_tools, :score, :integer, :default => 0
  end

  def self.down
    remove_column :mms_tools, :score
    remove_column :mms_tools, :mms_tool_category_id
    drop_table :mms_tool_categories
  end
end
