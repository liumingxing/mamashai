class BbrlController < ApplicationController
  before_filter :get_login_user, :except=>[:mobile, :mbile3]

  caches_page :invite_rank
   
  layout "main"
  
  def index
    conditions = ["1=1"]
    conditions << "posts.`from` = '#{params[:t].gsub("'", "")}'" if params[:t]
    if params[:page].to_i > 50
      params[:page] = 50
    end
    @posts = Post.not_hide.not_private.paginate(:conditions=>conditions.join(' and '), :page=>params[:page], :per_page=>params[:per_page]||24, :total_entries=>1200, :order=>"created_at desc")
    @recent_posts = Post.bbrl2.find(:all, :select=>"distinct(user_id), id, created_at", :order=>"id desc", :limit=>2)
  end
  
  def create_comment
    post = Post.find_by_id(params[:id])
    render :text=>"发生错误" if !post
    comment_params = {}
    comment_params[:comment] = {}
    comment_params[:comment][:content] = params[:content]
    comment = Comment.create_comment(comment_params, @user, post)
    render :partial=>"comment", :locals=>{:comment=>comment}
  end

  def mobile
    if request.env['HTTP_USER_AGENT'].to_s.downcase.include?('TencentTraveler')
      render :text=>"<img src='http://www.mamashai.com/images/advs/mobile/logo.png'/></br>亲，请到应用商店自行搜索并下载<b>宝宝日历</b>！" and return
    end
    render :layout=>false
  end

  def welcome
    redirect_to :action=>"mobile"
  end

  def download
    if params.keys.include?("yunq") || params.keys.include?(:yunq)
      if request.env['HTTP_USER_AGENT'].to_s.downcase.include?('iphone') || request.env['HTTP_USER_AGENT'].to_s.downcase.include?('ipad')
        redirect_to "https://itunes.apple.com/cn/app/id479480717"
      else
        send_file "#{::Rails.root.to_s}/public/downloads/yun.apk"
      end

      return
    end

    if request.env['HTTP_USER_AGENT'].to_s.downcase.include?('micromessenger')  #微信的提示页面
      render :layout=>false
    else
      if request.env['HTTP_USER_AGENT'].to_s.downcase.include?('iphone') || request.env['HTTP_USER_AGENT'].to_s.downcase.include?('ipad')
          redirect_to "http://www.mamashai.com/index/ipa"
      elsif request.env['HTTP_USER_AGENT'].to_s.downcase.include?('android')
          redirect_to "http://www.mamashai.com/index/apk"
      else
          redirect_to "http://www.mamashai.com/bbrl/mobile"
      end
    end
  end

  def select
    render :layout=>false
  end

  def mobile2
    render :layout=>false
  end

  def mobile3
    render :layout=>false
  end

  def baoming
    if !params[:name]
      flash[:notice] = "亲，请输入宝宝日历的注册昵称"
      redirect_to :action=>"mobile3" and return
    end
    if Baoming.find_by_name(params[:name])
      flash[:notice] = "亲，请不要重复报名"
      redirect_to :action=>"mobile3" and return
    end
    m = Baoming.new
    m.name = params[:name]
    m.save
    flash[:notice] = "报名成功"
    redirect_to :action=>"mobile3"
  end

  def star
    num = BbrlStar.first(:select=>"max(num) as n")['n'].to_i
    stars1 = BbrlStar.all(:conditions=>"tp = 'bbrl' and num = #{num}")
    ids = stars1.map{|s| s.user_id} << -1
    @users1 = User.all(:conditions=>"id in (#{ids.join(',')})")

    stars_rookies = BbrlStar.all(:conditions=>"tp = 'rookie' and num = #{num}")
    ids = stars_rookies.map{|s| s.user_id} << -1
    @users_rookies = User.all(:conditions=>"id in (#{ids.join(',')})")

    stars2 = BbrlStar.all(:conditions=>"tp = 'tupian' and num = #{num}")
    ids = stars2.map{|s| s.user_id} << -1
    @users2 = User.all(:conditions=>"id in (#{ids.join(',')})")

    stars4 = BbrlStar.all(:conditions=>"tp = 'birth_30' and num = #{num}")
    ids = stars4.map{|s| s.user_id} << -1
    @users4 = User.all(:conditions=>"id in (#{ids.join(',')})")

    stars5 = BbrlStar.all(:conditions=>"tp = 'birth_100' and num = #{num}")
    ids = stars5.map{|s| s.user_id} << -1
    @users5 = User.all(:conditions=>"id in (#{ids.join(',')})")

    stars6 = BbrlStar.all(:conditions=>"tp = 'birth_365' and num = #{num}")
    ids = stars6.map{|s| s.user_id} << -1
    @users6 = User.all(:conditions=>"id in (#{ids.join(',')})")
    render :layout=>false
  end

  def time
    params[:page] ||= 1
    @author = User.find(params[:id])
    @kids = UserKid.all(:conditions=>["user_id = ?", params[:id]])
    if params[:user_id] && params[:user_id].to_s.size > 0
      @browser = User.find(params[:user_id])
    end

    cond = ["posts.user_id=#{@author.id}"]
    #cond << ["forward_post_id is null"]
    #cond << ["(`from` <> 'taotaole' or `from` is null)"]
    if !params[:self]
      cond << ["is_private=0"]
    #  cond << ["(`from` <> 'dianping' or `from` is null)"]
    end

    if params[:kid_id] && params[:kid_id].size > 0
      if @kids.first.id == params[:kid_id].to_i        #是老大 
        cond << "(kid_id = #{params[:kid_id]} or kid_id is null)"
      else
        cond << "kid_id = #{params[:kid_id]}"
      end
    end

    order = "created_at desc"
    order = "created_at asc" if params[:order] == 'asc'
    @posts = Post.not_hide.paginate(:conditions=>cond.join(" and "), :order=>order, :page=>params[:page], :per_page=>20, :total_entries=>2000)
    render :layout=>false
  end

  def time_more
    @author = User.find(params[:id])
    @kids = UserKid.all(:conditions=>["user_id = ?", params[:id]])
    cond = ["posts.user_id=#{@author.id}"]
    #cond << ["forward_post_id is null"]
    #cond << ["(`from` <> 'taotaole' or `from` is null)"]
    if !params[:self]
      cond << ["is_private=0"]
    end
    if params[:kid_id] && params[:kid_id].size > 0
      if @kids.first.id == params[:kid_id].to_i        #是老大 
        cond << "(kid_id = #{params[:kid_id]} or kid_id is null)"
      else
        cond << "kid_id = #{params[:kid_id]}"
      end
    end

    order = "created_at desc"
    order = "created_at asc" if params[:order] == 'asc'
    @posts = Post.not_hide.paginate(:conditions=>cond.join(" and "), :order=>order, :page=>params[:page], :per_page=>20, :total_entries=>2000)
    if @posts.size == 0
      render :text=>"<div class='end'>到底了</div>" and return;
    end
    render :partial=>"time_post", :locals=>{:posts=>@posts, :kids => @kids}
  end

  def invite_rank
    @users = User.find_by_sql("select u.*, count(distinct(users.last_login_ip)) as c from users left join users u on u.id = users.invite_user_id where users.created_at > '2014-04-18' and users.created_at < '2014-05-19' and users.invite_user_id is not null and u.id <>93573 group by users.invite_user_id order by count(distinct(users.last_login_ip)) desc, u.posts_count desc limit 19")
    render :layout=>false
  end
end
