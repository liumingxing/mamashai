class Api::AsksController < Api::ApplicationController
  before_filter :authenticate!, :except=>%w(index show)
  before_filter :get_follow_user_ids, :only=>[:follow]
  # ==获取问答列表。
  #   [路径]: asks
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/asks.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - age_id 年龄段id
  # - tag_id 话题id
  # - tp 类型, yes为已解决, no为未解决, 空为全部
  # - count 指定每页返回的记录条数。默认值10
  # - page 页码,默认是1。
  #
  # ====示例
  #   curl "http://your.api.domain/asks.json?source=appkey"
  #
  def index
    params[:per_page] = params[:count]||10
    params[:page] ||= 1
    posts = Post.find_ask_posts(@user,params)
    render :json=>posts.to_json(:only=>Post.json_attrs+[:score])
  end

  # ==获取当前用户的问答列表。
  #   [路径]: asks/my
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/asks/my.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - age_id 年龄段id
  # - tag_id 话题id
  # - tp 类型, yes为已解决, no为未解决, 空为全部
  # - count 指定每页返回的记录条数。默认值10
  # - page 页码,默认是1。
  #
  # ====示例
  #   curl "http://your.api.domain/asks/my.json?source=appkey"
  #
  def my
    params[:per_page] = params[:count]||10
    params[:page] ||= 1
    posts = Post.find_user_ask_posts(@user,params)
    render :json=>posts.to_json(:only=>Post.json_attrs+[:score])
  end

  # ==获取当前用户的关注的问答列表。
  #   [路径]: asks/follow
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/asks/follow.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - age_id 年龄段id
  # - tag_id 话题id
  # - tp 类型, yes为已解决, no为未解决, 空为全部
  # - count 指定每页返回的记录条数。默认值10
  # - page 页码,默认是1。
  #
  # ====示例
  #   curl "http://your.api.domain/asks/follow.json?source=appkey"
  #
  def follow
    params[:per_page] = params[:count]||10
    params[:page] ||= 1
    params[:follow_user_ids] = @follow_user_ids
    posts = Post.find_user_ask_posts(@user,params)
    render :json=>posts.to_json(:only=>Post.json_attrs+[:score])
  end

  # ==查看单条问答。
  #   [路径]: asks/show
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/asks/show/:id.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - id 问答id
  #
  # ====示例
  #   curl "http://your.api.domain/asks/show/100021.json?source=appkey"
  #
  def show
    post = Post.asks.find(params[:id])
    render :json=>post.to_json(:only=>Post.json_attrs+[:score])
  end

  # ==发表问答，并上传图片接口
  #   [路径]:asks/update
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/asks/update.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - status 要发布的微博消息文本内容
  # - pic 要上传的图片。仅支持JPEG,GIF,PNG图片,为空返回400错误。目前上传图片大小限制为<5M。
  # - score 悬赏分数
  # - age_id 年龄段id
  #
  # ====示例
  #   curl -u "username:password" -F "pic=@1.png" -d "status=我要提问&score=10&age_id=1"
  #   "http://your.api.domain/asks/update.json?source=appkey"
  #
  def update
    attr = {:post=>{:content=>params[:status], :logo=>params[:pic], :age_id=>params[:age_id], :score=>params[:score]||0}}
    post = Post.create_post(attr,@user)
    render :text=>"error" and return if post.errors.present?
    render :json=>post.to_json(:only=>Post.json_attrs+[:score])
  end
  
  # ==发表回答接口
  #   [路径]： asks/answer
  #   [HTTP请求方式]:  POST
  #   [URL]: http://your.api.domain/asks/answer.json
  #   [是否需要登录]: true
  #
  # ====参数
  # - source: 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。 (必选)
  # - :id:  要评论的微博消息ID (必选)
  # - comment:  评论内容。必须做URLEncode,信息内容不超过140个汉字。 (必选)
  # - is_copy_post: 是否同时发表到微博 0为不发布， 1为发布
  #
  # ====示例
  #
  #   curl -u "username:password" -d "id=111904&comment=wahaha"
  #   "http://your.api.domain/asks/answer.json?source=appkey"
  #
  # ====注意
  # - 请求必须用POST方式提交
  # - 如果id不存在，将返回error
  #

  def answer
    render :text=>"error" and return if params[:comment].blank?
    post = Post.find(params[:id])
    attr = {:comment=>{:content=>params[:comment]}}
    attr[:is_copy_post] = params[:is_copy_post] if params[:is_copy_post].present?
    comment = Comment.create_comment(attr,@user,post)
    render :json=>comment
  end
  
  # ==根据问题ID返回回答列表
  #
  #   [路径]：asks/answers
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/asks/answers.json?source=appkey&id=1212
  #   [是否需要登录]: true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - :id:   指定要获取的评论列表所属的微博消息ID  (必选)
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/asks/answers.json?source=appkey&id=11212"
  #
  # ====注意
  # - 如果ID对应的微博不存在，返回null错误
  def answers 
    params[:per_page] = params[:count]||10
    params[:page] ||= 1
    post = Post.asks.find(params[:id])
    comments = Comment.find_post_comments(post, params)
    render :json=>comments.to_json(:only=>[:id, :content, :created_at, :rate])
  end


end
