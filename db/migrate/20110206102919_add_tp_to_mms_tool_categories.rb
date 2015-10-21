class AddTpToMmsToolCategories < ActiveRecord::Migration
  def self.up
    add_column :mms_tool_categories, :tp, :integer
    Mms::ToolCategory.create(:name=>"手机APP推荐", :tp=>1)
  end

  def self.down
    remove_column :mms_tool_categories, :tp
  end
end
