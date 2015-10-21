class Api::ArticlesController < Api::ApplicationController
	
  # ==获取资讯列表。
  #   [路径]: articles
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/articles.json
  #   [是否需要登录]： false
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - category_id 文章分类id。为空则查询所有分类下的资讯
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  #
  # ====示例
  #   curl "http://your.api.domain/articles.json?source=appkey&count=5&page=2&category_id=2"
  #
  def index
  	cond = []  << "articles.gou_brand_article_id is null and articles.gou_brand_story_id is null"
  	cond << "articles.article_category_id = #{params[:category_id]}" if params[:category_id].present?
	  cond << "article_category_id <> 51"
    cond << params[:cond] if params[:cond]
    articles = Article.publish.paginate(
    	:per_page => params[:count]||10,
      :page => params[:page]||1,
      :total_entries => 100,
    	:conditions =>cond.join(' and '),
    	:order => "articles.created_at desc, articles.id desc",
      :include=>"article_category")

    #render :text=>"null" and return if articles.size == 0
    render :json=>articles
  end
  
  # ==查看单条资讯。
  #   [路径]: articles/show
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/articles/show/:id.json
  #   [是否需要登录]： false
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - id 文章id。(必选)
  #
  # ====示例
  #   curl "http://your.api.domain/articles/show/100.json?source=appkey"
  #
  def show
  	article = Article.find(params[:id])
    article.view_count += 1
    article.save
  	render :json=>article.to_json(:include=>{:article_content=>{:only=>[:content]}})
  end
end
