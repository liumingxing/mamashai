class MmsToolsController < ApplicationController
  before_filter :get_login_user
  layout 'main'
  
  def index
    cond = ["tuan_id is null"]
    cond << "mms_tool_category_id = #{params[:id]}" if params[:id] != 'all' && params[:id]
    if params[:tp] == 'tool'
      cond << "tool =1 " 
    else
      cond << "tool = 0"
    end
    cond << "step_id = #{params[:age]}" if params[:age]
    @category = Mms::ToolCategory.find(params[:id]) rescue Mms::ToolCategory.first
    @categories = Mms::ToolCategory.find(:all, :order=>"position")
    @tools = Mms::Tool.paginate :conditions=>cond.join(' and '),:order=>"#{params[:order] || 'created_at'} desc",:page => params[:page], :per_page =>15
    @no_recommand = true
  end
  
  def hot
    @category = Mms::ToolCategory.find(params[:id]) rescue Mms::ToolCategory.first
    @categories = Mms::ToolCategory.all
    @tools = Mms::Tool.paginate :conditions=>["mms_tool_category_id=?",@category.id],:order=>"users_count desc",:page => params[:page], :per_page =>10
    render :action=>"index"
  end

  def show
    @tool = Mms::Tool.find(params[:id])
    if @tool.tool
      redirect_to @tool.url
    else
      @other_tools_1 = Mms::Tool.all(:conditions=>["id <> ? and mms_tool_category_id = ?",@tool.id, @tool.mms_tool_category_id], :limit=>4, :order=>"users_count")
      @other_tools_2 = Mms::Tool.all(:conditions=>["id <> ? and step_id = ?",@tool.id, @tool.step_id], :limit=>4, :order=>"users_count")  
    end
  end
  
  def download
    redirect_to :action=>:index and return if params[:id].blank?
    @tool = Mms::Tool.find(params[:id])
    tuan = @tool.tuan
    
    @tool.update_attributes({:users_count => @tool.users_count+1})
     
    if @user
          download = Mms::ToolsDownload.new
          download.user_id = @user.id
          download.tool_id = @tool.id
          download.save
    end
    send_file File.join(::Rails.root.to_s,'public',@tool.pdf.url)
  end
  
  private
  def redirect_to_set_app
    if Mms::App.find_by_id(9) and UserApp.find_by_user_id_and_mms_app_id(@user.id,9).blank?
      redirect_to "/apps/set_app?id=9"
    end
  end
end
