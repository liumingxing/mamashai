class Mms::ToolsDownload < ActiveRecord::Base
  set_table_name :mms_tools_downloads
  belongs_to :tool, :class_name=>"Mms::Tool"
  belongs_to :user
end
