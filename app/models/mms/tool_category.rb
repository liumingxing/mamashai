class Mms::ToolCategory < ActiveRecord::Base
  self.table_name = "mms_tool_categories"
  has_many :mms_tools, :foreign_key => "mms_tool_category_id", :class_name=>"Mms::Tool", :dependent => :destroy
  validates_presence_of :name, :message => '不能为空'
  
  named_scope :apps, :conditions=>["mms_tool_categories.tp = 1"]
  named_scope :normal, :conditions=>["mms_tool_categories.tp is null"] 
end
