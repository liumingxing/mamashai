class Api::TrendsController < Api::ApplicationController
  before_filter :authenticate!
  
  # ==获取某用户的话题。
  #   [路径]: trends
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/trends.json
  #   [是否需要登录]： true
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - id 用户id。为空则查询当前用户的话题
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/trends.json?source=appkey&count=5&page=2&id=108"
  #
  def index
    @user = User.find params[:id] if params[:id].present?
    tags = @user.tags.paginate(:page=>params[:page]||1, :per_page=>params[:count]||10)
    render :json=>tags
  end
  
  
  # ==获取某话题下的微博消息。 
  #   [路径]: trends/statuses 
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/trends/statuses.json
  #   [是否需要登录]： true
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - name  话题关键词。为空则获取所有话题中的微博信息
  # - count  指定每页返回的记录条数。默认值10
  # - page  页码,默认是1。
  #
  # ====示例
  #   curl -u "username:password"
  #   "http://your.api.domain/trends/statuses.json?source=appkey&count=5&page=2&name=宝宝"
  #
  def statuses 
    params[:per_page] = params[:count]||10
    posts = Post.find_tag_posts((URI.decode(params[:name]) rescue ""),params)
    render :json=>posts
  end
  
  # ==关注某话题。
  #   [路径]: trends/follow 
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/trends/follow.json
  #   [是否需要登录]： true
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - trend_name 要关注的话题关键词。 
  #
  # ====示例
  #   curl -u "username:password" -d "trend_name=JAVA"
  #   "http://your.api.domain/trends/destroy.json?source=appkey"
  #
  # ====注意事项
  # - 成功返回ok，失败返回error
  # 
  def follow
  	tag = Tag.find_or_create_by_name(params[:trend_name])
  	if UserTag.exists?(:user_id=>@user.id, :tag_id=>tag.id)
		render :text => 'error'  		
  	else
	  	@user.tags << tag
	  	render :text => 'ok'
  	end
  end
  
  # ==取消对某话题的关注。
  #   [路径]: trends/destroy
  #   [HTTP请求方式]: DELETE/POST
  #   [URL]: http://your.api.domain/trends/destroy.json
  #   [是否需要登录]： true
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - trend_id 	要取消关注的话题ID。 
  #
  # ====示例
  #   curl -u "username:password" -X DELETE
  #   "http://your.api.domain/trends/destroy.json?source=appkey&trend_id=1"
  #
  def destroy
  	t = UserTag.find_by_user_id_and_tag_id(@user.id, params[:trend_id])
  	if t.present? and t.destroy
  		render :text => 'ok'
  	else
  		render :text => 'error'
  	end
  end
  
end