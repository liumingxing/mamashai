class Mms::ArticleController < Mms::MmsBackEndController
  #uses_tiny_mce(:options => Article.tiny_advance_options,:only => [:edit, :new])
  
  def category
    page = (params[:page] unless params[:page].blank?) || 1
    @article_categories = ArticleCategory.paginate(:per_page => 20,:page =>page, :conditions=>"parent_id is null or parent_id = 0", :order => "created_at DESC")
  end
  
  def category_new
    
  end
  
  def create_category
    if ArticleCategory.create(params[:category]).errors.blank?
      flash[:notice] = "资讯栏目新建成功！"
      redirect_to :action => :category
    else
      flash[:notice] = "资讯栏目新建失败！"
      redirect_to :action => :category_new
    end
  end
  
  def category_show
    @article_category = ArticleCategory.find(params[:id])
  end
  
  def category_edit
    @article_category = ArticleCategory.find(params[:id])
  end
  
  def category_update
    category = ArticleCategory.find(params[:id])
    if category.update_attributes(params[:article_category])
      flash[:notice] = "修改资讯栏目成功！"
      redirect_to :action => :category
    else
      flash[:notice] = "修改资讯栏目失败！"
      redirect_to :back
    end
  end
  
  def category_destroy
    category = ArticleCategory.find(params[:id])
    flash[:notice] = '删除资讯栏目成功！'
    flash[:notice] = '删除资讯栏目失败！' unless category.destroy
    redirect_to :action => :category
  end
  
  def index
    page = (params[:page] unless params[:page].blank?) || 1
    conditions = ['article_categories.tp <= 0']
    conditions << "article_category_id = #{params[:tp]}" if params[:tp]
    @articles = Article.paginate(:per_page => 20, :page =>page, :include => [:article_category], :order => "articles.created_at DESC", :conditions => conditions.join(" and "))
  end
  
  def new
    @categories = ArticleCategory.all(:conditions => ['tp <= 0']).map{|t| [t.name, t.id]}
    @article = Article.new(:tags=>"")
  end
  
  def create
    if params[:article_content][:content].blank?
      flash[:notice] = "资讯内容不能为空！"
      redirect_to :back
    else
      ::Article.transaction do
        @article = ::Article.create(params[:article])
        @article.tags = params[:tags].join(",") if params[:tags]
        if @article.errors.blank?
          ::ArticleContent.create(:content => params[:article_content][:content], :article_id => @article.id) 
          user = ::User.find_by_name(@article.author)
          if user
            @article.user_id = user.id
            @article.save
          end
        end
      end
      if @article.errors.blank?
        flash[:notice] = '新建资讯成功！'
        redirect_to :action => :index
      else
        flash[:notice] = '新建资讯失败！'
        redirect_to :back
      end
    end
  end
  
  def show
    @article = Article.find(params[:id], :include => [:article_content, :article_category])
  end
  
  def edit
    @categories = ArticleCategory.all(:conditions => ['tp <= 0']).map{|t| [t.name, t.id]}
    @article = Article.find(params[:id], :include => "article_content")
    @article_content = @article.article_content
  end
  
  def update
    if params[:article_content][:content].blank?
      flash[:notice] = "资讯内容不能为空！"
      redirect_to :back
    else
      @article = Article.find(params[:id])
      Article.transaction do
        @article.update_attributes(params[:article])
        @article.tags = params[:tags].join(",") if params[:tags]
        if @article.errors.blank?
          @article.article_content.update_attribute(:content, params[:article_content][:content]) 
          user = ::User.find_by_name(@article.author)
          @article.user_id = nil
          if user
            @article.user_id = user.id
          end
          @article.save
        end
      end
      if @article.errors.blank?
        flash[:notice] = '修改资讯成功！'
        redirect_to :action => :index
      else
        flash[:notice] = '修改资讯失败！'
        redirect_to :back
      end
    end
  end
  
  def destroy
    @article = Article.find(params[:id])
    flash[:notice] = '删除资讯成功！'
    flash[:notice] = '删除资讯失败！' unless @article.destroy
    redirect_to :action => :index, :page=>params[:page]
  end
  
  def publish
    article = Article.find(params[:id])
    flash[:notice] = "修改资讯发布状态成功！"
    flash[:notice] = "修改资讯发布状态失败！" if !article.update_attribute(:state, "已发布")
    redirect_to :action => :index
  end
  
  def unpublish
    article = Article.find(params[:id])
    flash[:notice] = "修改资讯发布状态成功！"
    flash[:notice] = "修改资讯发布状态失败！" if !article.update_attribute(:state, "未发布")
    redirect_to :action => :index
  end
  
  def find
    page = (params[:page] unless params[:page].blank?) || 1
    @articles = Article.paginate(:per_page => 20, :page =>page, :conditions=>["title like ? or article_contents.content like ?","%#{params[:search][:title]}%", "%#{params[:search][:title]}%"], :include => [:article_content, :article_category], :order => "articles.article_category_id DESC, articles.created_at DESC")
  end

  def create_post
    user = ::User.find_by_name('妈妈晒')
    post = Post.create_post(params, user) if user
    redirect_to :action=>"index", :page=>params[:page]
  end
end
