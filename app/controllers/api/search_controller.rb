class Api::SearchController < Api::ApplicationController
    # ==返回与关键字相匹配的微博。
    #   [路径]: search
    #   [HTTP请求方式]: GET
    #   [URL]: http://your.api.domain/search.json
    #   [是否需要登录]： false
    #
    # ====参数
    # - q  搜索的关键字。必须进行URL Encode(必选)
    # - count  指定每页返回的记录条数。默认值10
    # - page  页码,默认是1。
    #
    # ====示例
    #   curl -u "username:password" 
    #   "http://your.api.domain/search.json?source=appkey&q=%E5%A6%88%E5%A6%88%E6%99%92"
    #
    def index
        render :json=>[] and return if params[:q].blank?
        posts = Post.paginate(:all,:conditions=>["posts.is_hide <> 1 and posts.content like ?", "%#{URI.decode(params[:q])}%"], :include=>[:user], :order=>"posts.created_at desc",:per_page=>params[:count]||10, :page=>params[:page]||1)
        render :json=>posts
    end

end