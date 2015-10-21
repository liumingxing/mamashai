class Api::AppsController < Api::ApplicationController
  before_filter :authenticate!
  # ==获取推荐应用列表。
  #   [路径]: apps
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/apps.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - count 指定每页返回的记录条数。默认值10
  # - page 页码,默认是1。
  #
  # ====示例
  #   curl "http://your.api.domain/apps.json?source=appkey"
  #
  def index
    category = Mms::ToolCategory.apps.first
    render :text => 'error' and return if category.blank?
    tools = Mms::Tool.paginate(:all,
    	:conditions=>["mms_tool_category_id=? and tuan_id is NULL",category.id],
    	:order=>"created_at desc",:page => params[:page]||1, :per_page =>params[:count]||10)
  	render :json=>tools
  end

  # ==通过id查看单个推荐应用。
  #   [路径]: apps/show
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/apps/show/:id.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - id 推荐应用id
  #
  # ====示例
  #   curl "http://your.api.domain/apps/show/12.json?source=appkey"
  #
  def show
  	tool = Mms::Tool.first(:conditions=>["mms_tools.id=? and mms_tools.tuan_id is null and mms_tool_categories.tp = ?",params[:id],1], :joins=>"inner join mms_tool_categories on mms_tools.mms_tool_category_id = mms_tool_categories.id")
  	render :json=>tool.to_json(:only=>Mms::Tool.json_attrs+[:content])
  end
  
  
  # ==通过id下载单个推荐应用。
  #   [路径]: apps/download
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/apps/download/:id.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - id 推荐应用id
  #
  # ====示例
  #   curl "http://your.api.domain/apps/download/12.json?source=appkey"
  #
  # ====注意事项
  # - 推荐应用支持积分功能，后台对相应的应用下载所需积分进行设置，如果当前用户积分小于应用下载所需积分，则返回error
  #
  def download
    tool = Mms::Tool.first(:conditions=>["mms_tools.id=? and mms_tools.tuan_id is null and mms_tool_categories.tp = ?",params[:id],1], 
    :joins=>"inner join mms_tool_categories on mms_tools.mms_tool_category_id = mms_tool_categories.id", :readonly => false)
    render :text => 'error' and return if tool.blank? or @user.score < tool.score
    ActiveRecord::Base.transaction do
      tool.update_attributes({:users_count => tool.users_count+1})
    end
    send_file File.join(::Rails.root.to_s,'public',tool.pdf.url)
  end

end