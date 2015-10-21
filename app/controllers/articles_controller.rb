class ArticlesController < ApplicationController 
  before_filter :get_login_user
  before_filter :need_login_user, :only => [:create_article_comment]
  
  layout "main"
  
  def index
    @title = "育儿宝典"
    
    @roots = ArticleCategory.roots
     
    parent_id =  params[:c1] || @roots[0].id
    @roots_2 = ArticleCategory.find(:all, :conditions=>"parent_id = #{parent_id.to_s.gsub("'", "")}")
    params[:c2] ||= @roots_2[0].id if params[:c1]
    
    if params[:id].blank?
      cond = ["1=1"]
      cond << "tags like '%#{Age.find(params[:age]).name}%'" if params[:age] && params[:age].size > 0 && params[:age].to_i > 0
      cond << "tags like '#{params[:tag]}'" if params[:tag]
      order = "created_at DESC" if params[:order].blank?
      order = "view_count DESC" if params[:order] == "views"
      date = Date.today-7 and @tp = "week" if params[:tp] == "week"
      date = Date.today-30 and @tp = "month" if params[:tp] == "month"
      cond << "articles.created_at > '#{date.to_s}'" unless date.blank?
      cond << "article_category_id = '#{params[:c2]}'" if params[:c2]
#      cond << ["article_category_id = ?", @roots_2[0].id] if params[:c1] && !params[:c2] 
      @articles = Article.publish.paginate(:per_page => 15,:page => params[:page].blank? ? 1 : params[:page], :conditions => cond.join(" and "), :order => "#{order}")
    else
      @articles = Article.publish.paginate(:per_page => 15,:page => params[:page].blank? ? 1 : params[:page], :conditions => ['article_category_id = ?', params[:c2]], :order => "created_at DESC")
    end
  end
  
  def create_article_good
    render(:layout => false, :text => "登录用户才能添加好评！") and return false if @user.blank?
    exist_good = ArticleGood.first(:conditions => {:user_id => @user.id, :article_id => params[:id]})
    unless exist_good
      new_good = ArticleGood.create(:article_id => params[:id], :user_id => @user.id)
      render(:layout => false, :text => new_good.article.article_goods_count+1); 
      return
    end
    render(:layout => false, :text => "您已经给这篇文章加过好评!");
  end
  
  def create_article_comment
    article = Article.find(params[:id])
    article_comment = ArticleComment.create_article_comment(params, @user, article) if article.present?

    redirect_to :action => :article, :id => article.id
  end
  
  def article
    @article = Article.find(params[:id], :include => [:article_comments], :order => "article_comments.created_at DESC")
    @article.view_count += 1
    @article.save
    
    @title = "#{@article.title} - 育儿宝典"
    
    @relate_articles = Article.find(:all, :conditions=>"article_category_id = #{@article.article_category_id} and id <> #{@article.id}", :limit=>10)
  end
  
  def period_articles
    @age = Age.find(params[:age])
    render :partial=>"period_article", :locals=>{:age=>@age}
  end
  
  def m_index
    @articles = Article.publish.paginate(:per_page => 10,:page => params[:page]||1, :conditions => ['article_category_id = ?', params[:id]], :order => "created_at DESC")
  end
  
  def m_show
    @article = Article.find(params[:id], :order => "articles.created_at DESC")
    render :text=>@article.article_content.content
  end
  
end
