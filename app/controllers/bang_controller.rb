class BangController < ApplicationController
  before_filter :get_login_user
  layout "main"
  
  def index
    if !params[:age_id] || !Age.find(params[:age_id])
      redirect_to "/bang?age_id=2" and return
    end
    
    @categories = Mms::ToolCategory.find(:all, :order=>"position")
    #@posts = Post.search '', :page=>params[:page], :per_page=>15, :order=>"id desc", :with=>{:age_id=>params[:age_id]}
    @posts = Post.paginate :page=>params[:page], :per_page=>15, :total_entries=>1000, :order=>"id desc", :conditions=>"age_id = #{params[:age_id]}"
    
    cond = ["tuan_id is null"]
    cond << "mms_tool_category_id = #{params[:c_id]}" if params[:c_id] != 'all' && params[:c_id]
    cond << "step_id = #{params[:age_id]}" if params[:age_id]
    @tools = Mms::Tool.paginate :conditions=>cond.join(' and '), :order=>"#{params[:order] || 'created_at'} desc",:page => params[:page], :per_page =>6
    
    cond = ["1=1"]
    cond << "tags like '%#{Age.find_by_id(params[:age_id]).name}%' " if params[:age_id]
    @relate_articles = Article.find(:all, :conditions=>cond.join(' and '), :order=>"id desc", :limit=>5)
    
    cond = ["1=1"]
    cond << "age_id = #{params[:age_id]} " if params[:age_id]
    @relate_topics = AgeTag.find(:all, :conditions=>cond.join(' and '), :limit=>10, :order=>"updated_at desc")
    
    @age = Age.find(params[:age_id])

    @kind = @age.name
    @kind = '孕期' if params[:age_id].to_i < 2
    @kind = '0到3' if params[:age_id].to_i >= 3 && params[:age_id].to_i <=5
  end
end
