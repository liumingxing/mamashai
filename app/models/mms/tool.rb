class Mms::Tool < ActiveRecord::Base
  set_table_name :mms_tools
  belongs_to :mms_tool_category, :class_name=>"Mms::ToolCategory",:counter_cache => :mms_tools_count
  belongs_to :tuan
  validates_presence_of :name,:logo, :message => '不能为空'
  upload_column :logo ,:process => '450x540', :versions => {:thumb160=>"c160x120", :thumb99 => "c99x125", :thumb106=>"c106x148"}, :store_dir => proc{|record| "mms_tools/#{record.id}/logo"}  
  upload_column :pdf, :store_dir => proc{|record| "mms_tools/#{record.id}/pdf"}
  
  ########json##########
  # ==json_attrs 输出字段
  # * id: ID
  # * name: 名称
  # * content: 应用详细介绍(只有查看单条应用时返回该字段)
  # * created_at: 创建时间
  # * score: 下载积分
  # * users_count: 下载次数
  # 
  def self.json_attrs
    %w{id name created_at score users_count}
  end
  
  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址
  # 
  def self.json_methods
    %w{logo_url logo_url_thumb99}
  end
  
  # 图片地址
  def logo_url
    logo.try(:url)
  end
  
  # 缩略图地址
  def logo_url_thumb99
    logo.try(:thumb99).try(:url)
  end
  
  def as_json(options = {})
    options[:only] ||= Mms::Tool.json_attrs
    options[:methods] ||= Mms::Tool.json_methods
    super options
  end
  
end
