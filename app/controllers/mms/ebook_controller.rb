class Mms::EbookController < Mms::MmsBackEndController
  
  def index
    page = (params[:page] unless params[:page].blank?) || 1
    @ebooks = EbookTopic.paginate(:per_page => 20, :page =>page, :order => "id desc")
  end
  
  def new
    @ebook = EbookTopic.new()
    @authors = ColumnAuthor.all.collect {|a|[ a.user.name,a.user.id]}
    @ages = Age.all
  end
  
  def create
    ebook = EbookTopic.new(params[:ebook])
    ebook.step_id = params[:step_id].join(',') if params[:step_id]
    
    ebook.user_id = ""
    ebook.ebook_author.split(',').each_with_index do |author,index|
      user = ::User.find_by_name(author)
      if user == nil
#        flash[:notice] = "作者#{author}不存在！"
#        redirect_to :back
#        return
      else
        ebook.user_id << user.id.to_s
        ebook.user_id << "," unless index+1 == ebook.ebook_author.split(',').count
      end
    end
    
    unless params[:ebook_baidu_apps].blank?
      ebook.ebook_baidu_apps = ""
      params[:ebook_baidu_apps].each_with_index do |app,index|
       # ebook.ebook_baidu_apps << app
       # ebook.ebook_baidu_apps << "," unless index == params[:ebook_baidu_apps].count - 1
        baiduapp = BaiduApp.find(app)
        baiduapp.ebook_topic_id = @ebook.id

        baiduapp.save
      end
    end
    unless params[:age_id].blank?
      ebook.age_id = ''
      params[:age_id].each_with_index do |age,index|
        ebook.age_id << age
        ebook.age_id << "," unless index == params[:age_id].count - 1
      end
    end
    
    ebook.save
    redirect_to :action => :index
  end
  
  def edit
     @authors = ColumnAuthor.all.collect {|a|[ a.user.name,a.user.id]}
     @ebook = EbookTopic.find(params[:id])
     @ages = Age.all
     @ebook_app = @ebook.baidu_app.find(:all, :select => "id").collect{|t| t.id}.uniq
  end
  
  def update
    @ebook = EbookTopic.find_by_id(params[:ebook][:id])
    ebook = params[:ebook]
    #ebook.id = @ebook.id

    ebook["user_id"] = ""
    ebook["ebook_author"].split(',').each_with_index do |author,index|
      user = ::User.find_by_name(author)
      if user == nil
        flash[:notice] = "作者#{author}不存在！"
        redirect_to :back
        return
      else
        ebook["user_id"] << user.id.to_s
        ebook["user_id"] << "," unless index+1 == ebook["ebook_author"].split(',').count
      end
    end
    unless params[:ebook_baidu_apps].blank?
       params[:ebook_baidu_apps].each_with_index do |app,index|
          baiduapp = BaiduApp.find(app)
          baiduapp.ebook_topic_id = @ebook.id
          baiduapp.save
       end
    end
    unless params[:age_id].blank?
      ebook["age_id"] = ''
      params[:age_id].each_with_index do |age,index|
        ebook["age_id"] << age
        ebook["age_id"] << "," unless index == params[:age_id].count - 1
      end
    end
    @ebook.step_id = params[:step_id].join(',') if params[:step_id]
    @ebook.update_attributes(ebook)
    if @ebook.errors.blank?
      flash[:notice] = '修改电子书成功！'
      redirect_to :action => :index
    else
      flash[:notice] = '修改电子书失败！'
      redirect_to :back
    end
  end
  
  def find
    page = (params[:page] unless params[:page].blank?) || 1
    if params[:search][:title].blank?
      redirect_to :action => :index
      return
    end
    @ebooks = EbookTopic.paginate(:per_page => 20, :page =>page, :conditions=>["ebook_title like ? or ebook_abstruct like ?","%#{params[:search][:title]}%", "%#{params[:search][:title]}%"], :order => "id DESC")
    render :partial => 'search_result', :locals => {:ebooks => @ebooks}
  end
  
  def publish
    article = EbookTopic.find(params[:id])
    flash[:notice] = "修改电子书发布状态成功！"
    flash[:notice] = "修改电子书发布状态失败！" if !article.update_attribute(:ebook_status, "上线")
    redirect_to :action => :index
  end
  
  def unpublish
    article = EbookTopic.find(params[:id])
    flash[:notice] = "修改电子书发布状态成功！"
    flash[:notice] = "修改电子书发布状态失败！" if !article.update_attribute(:ebook_status, "下线")
    redirect_to :action => :index
  end
  
  def destroy
    @ebook = EbookTopic.find(params[:id])
    flash[:notice] = '删除电子书成功！'
    flash[:notice] = '删除电子书失败！' unless @ebook.destroy
    redirect_to :action => :index
  end
  
end