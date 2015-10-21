class Mms::BaiduAppController < Mms::MmsBackEndController
  
  def index
    page = (params[:page] unless params[:page].blank?) || 1
    @baiduapp = BaiduApp.paginate(:per_page => 20, :page =>page, :order => "id desc")
  end
  
  def new
    @ebooks = EbookTopic.all
    @baiduapp = BaiduApp.new()
  end
  
  def create
    baiduapp = BaiduApp.new(params[:baiduapp])
    baiduapp.save
    redirect_to :action => :index
  end
  
  def edit
    @ebooks = EbookTopic.all
    @baiduapp = BaiduApp.find(params[:id])
  end
  
  def update
    @baiduapp = BaiduApp.find(params[:baiduapp][:id])
    @baiduapp.update_attributes(params[:baiduapp])
    if @baiduapp.errors.blank?
      flash[:notice] = '修改百度APP应用成功！'
      redirect_to :action => :index
    else
      flash[:notice] = '修改百度APP应用失败！'
      redirect_to :back
    end
  end
  
  def destroy
    @baiduapp = BaiduApp.find(params[:id])
    flash[:notice] = '删除百度APP应用成功！'
    flash[:notice] = '删除百度APP应用失败！' unless @ebook.destroy
    redirect_to :action => :index
  end
  
  def find
     page = (params[:page] unless params[:page].blank?) || 1
      if params[:search][:title].blank?
        redirect_to :action => :index
        return
      end
      @baiduapp = BaiduApp.paginate(:per_page => 20, :page =>page, :conditions=>["app_name like ? or app_desc like ?","%#{params[:search][:title]}%", "%#{params[:search][:title]}%"], :order => "id DESC")
      render :partial => 'search_result', :locals => {:baiduapp => @baiduapp}
  end
  
end