class Api::UsersController < Api::ApplicationController
  #before_filter :authenticate!, :except=>%w(same_city_users)
  # ==按用户ID或昵称返回用户资料以及用户的最新发布的一条微博消息。 
  #   [路径]: users/show 
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/users/show/:id.json
  #   [是否需要登录]： true
  # 
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - :id  用户id
  #
  # ====示例
  #   curl -u "username:password" 
  #   "http://your.api.domain/users/show/:id.json?source=appkey"
  # 
  def show
    if params[:id].index('_')
      users = User.find(:all, :conditions=>"id in (#{params[:id].split('_').join(',')})")
      render :json=>users.to_json(:include=>{:last_post=>{:only=>Post.json_attrs}, :user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}})
    else
      if params[:v] == "2"
        user = User.find_by_id(params[:id])
        if user
          render :json=>user.to_json(:include=>{:last_post=>{:only=>Post.json_attrs}, :user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}})
        else
          render :text=>"deleted"
        end
      else
        user = User.find(params[:id])
        render :json=>user.to_json(:include=>{:last_post=>{:only=>Post.json_attrs}, :user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}})
      end
    end    
  end
  
  #同城妈妈
  #可传入user_id, province_id, city_id
  def same_city_users
    if !params[:user_id] && !params[:province_id] && !params[:city_id]
      render :json=>{:error=>"亲，请选择城市!"} and return
    end

    conditions = ["1=1"]
    if params[:province_id] || params[:city_id]           #传入的省市优先
      conditions << "users.province_id = #{params[:province_id]}" if params[:province_id]  #传入了省
      conditions << "users.city_id = #{params[:city_id]}" if params[:city_id]              #传入了市
    else
      user = User.find(params[:user_id])
      conditions << "users.province_id = #{user.province_id}" if user.province_id
      conditions << "users.city_id = #{user.city_id}" if user.city_id
      render :json=>{:error=>"亲，您的个人资料里没有设置城市"} and return if !user.province_id && !user.city_id
    end

    users = User.paginate(:page=>params[:page], :conditions=>conditions.join(' and '), :per_page=>params[:per_page]||12, :order=>"users.last_login_at + users.posts_count*1000000 desc")
    render :json=>users
  end

  def high_score_users
    render :json=>Rails.cache.fetch("high_score_users_#{params[:page]}", :expires_in=>1.day){
      users = User.paginate(:order=>"score desc", :page=>params[:page], :per_page=>10, :total_entries=>1000)
      users.as_json
    }
  end
  
end