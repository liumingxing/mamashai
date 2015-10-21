class Mms::PostsController < Mms::MmsBackEndController
  
  def index
    @posts = Post.paginate :page => params[:page], :per_page => 30, :order => 'id desc'
  end
  
  def show
    @post = Post.find(params[:id])
  end
  
  def edit
    @post = Post.find(params[:id])
  end
  
  def update
    @post = Post.find(params[:id])
    case request.method
    when :post
      @post.update_attributes(params[:post])
    end
    redirect_to :action => 'index'
  end
  
  def destroy
    case request.method
    when :delete
      @post = Post.find(params[:id])
      @post.destroy
    end
    redirect_to :action => "index"
  end
  
  def search
    @start_date = Date::civil(params[:start][:year].to_i, params[:start][:month].to_i,params[:start][:day].to_i)
    @end_date = Date::civil(params[:end][:year].to_i, params[:end][:month].to_i, params[:end][:day].to_i)
    @search_key=params[:search_key]
    
    @posts = Post.paginate(:page=>params[:page], :per_page=>30, :conditions=>["content like ? and created_at between ? and ?", '%'+@search_key+'%', @start_date, @end_date+1], :order => 'id desc')
    render :action=>:index
  end

  def links
    @links = Link.find :all, :order => "sort asc, created_at asc"
  end

  def create_link
    Link.create :link_url => params[:link_url], :name => params[:name]
    redirect_to :action => :links
  end

  def delete_link
    link = Link.find_by_id params[:id]
    if link
      link.destroy
      render :text => "友情链接删除成功"
      return
    end

    render :text => "友情链接删除失败"
    return
  end

  def change_sort
    link = Link.find_by_id params[:id]
    if link
      link.update_attribute :sort, params[:sort]
      render :text => "序列更改成功"
      return
    end

    render :text => "序列更改失败"
    return
  end
  
end
