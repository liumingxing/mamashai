class Api::FavoritesController < Api::ApplicationController
  before_filter :authenticate!
  
  # ==返回登录用户最近收藏的微博消息，和用户在主站上“我的收藏”页面看到的内容是一致的。 
  #   [路径]: favorites
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/favorites.json
  #   [是否需要登录]： true
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  #
  # ====示例
  #   curl -u "username:password" 
  #   "http://your.api.domain/favorites.json?source=appkey&count=5&page=2"
  #
  def index
    params[:per_page] = params[:count]||10
    posts = Post.find_favorite_posts(@user,params)
    render :json=>posts
  end
  
  
  # ==添加收藏 
  #   [路径]: favorites/create 
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/favorites/create.json
  #   [是否需要登录]： true
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - id  要收藏的微博消息ID。
  #
  # ====示例
  #   curl -u "username:password" -X POST
  #   "http://your.api.domain/favorites/create.json?source=appkey&id=100041"
  #
  # ====注意
  # - 收藏成功返回ok，失败则返回error
  def create
    @post = Post.find(params[:id])
    params[:favourite] = {:content=>params[:content]}
    @favorite_post = FavoritePost.create_favorite_post(@post,@user,params)
    render :text => @favorite_post.errors.empty? ? "ok" : "error"
  end

  # ==删除当前用户收藏的微博信息 
  #   [路径]: favorites/destroy/:id 
  #   [HTTP请求方式]: POST/DELETE
  #   [URL]: http://your.api.domain/favorites/destroy/:id .json
  #   [是否需要登录]： true
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - id  要删除的已收藏的微博消息ID。
  #
  # ====示例
  #   curl -u "username:password" -X POST
  #   "http://your.api.domain/favorites/destroy/112221.json?source=appkey"
  #
  # ====注意
  # - 删除成功返回ok，失败则返回error
  def destroy
    FavoritePost.delete_favorite_post(params,@user)
    render :text => 'ok'
  end  
  
end