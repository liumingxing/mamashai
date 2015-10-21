class Mms::DataController < Mms::MmsBackEndController
  def users_data
    @title = "用户统计"
  end

  def users
    @users = ::User.paginate(:select=>"distinct users.*", :page=>params[:page], :per_page=>30, :joins=>"left join investigates on users.id = investigates.user_id left join ddh_orders on ddh_orders.user_id = users.id", :order=>"investigates.id desc, ddh_orders.id desc, users.id desc")
  end

  def user2
    @users = ::User.paginate(:select=>"distinct users.*", :page=>params[:page], :per_page=>30, :joins=>"left join investigates on users.id = investigates.user_id left join ddh_orders on ddh_orders.user_id = users.id", :order=>"investigates.id desc, ddh_orders.id desc, users.id desc", :total_entries=>90)
  end

  def users_lmx
    @tongjis = TongjiDay.paginate(:per_page=>30, :page=>params[:page], :limit=>30, :order=>"id desc")
  end

  def users_tracy
    @tongjis = TongjiDay.paginate(:conditions=>"day >= '2014-07-01'", :per_page=>3000, :page=>params[:page], :order=>"id desc")
  end
  
  def users_analysis
    @search_user = ::User.new
  end
  
  def new_users
    @title = "用户统计-新增注册用户表"
    render :action=>"data"
  end
  
  
  def keyword_signups_data 
    if params[:search].blank?
      today = Date.today
    else
      @search = User.new(params[:search])
      today = @search.created_at.to_date
    end
    
    @keywords = DayKeywordSignup.find(:all,:conditions=>['day = ?',today])
  end
  
  def cc_report_new_users
    return render_404 unless @mms_user
    search = ::User.new(params[:search])
    return render_404 if search.blank? or search.created_at.blank?
    @date1 = search.created_at.to_date
    @date2 = search.last_login_at.to_date
    @users = ::User.find(:all,:limit=>2000,:conditions=>['users.created_at > ? and users.created_at < ?',@date1,@date2+1],:include=>[:industry,:province,:city,:invite_user])
    render :layout=>'data_reports'
  end
  
  def search_users
    @title = "用户分析-用户行为表"
    render :action=>"data"
  end
  
  def cc_report_search_users
    return render_404 unless @mms_user
    @search_user = ::User.new(params[:search_user])
    @users = ::User.find_search_users(Mms::User.find_user(@mms_user),@search_user,params,'users.*') 
    render :layout=>'data_reports'
  end
  
  def posts_count
    @title = "晒品统计-晒品量统计"
    render :action=>"data"
  end
  
  def cc_report_posts_count
    return render_404 unless @mms_user
    search = ::User.new(params[:search])
    @date1 = search.created_at.to_date
    @date2 = search.last_login_at.to_date
    join_str = "inner join posts on posts.user_id = users.id"
    select_str = 'users.*,count(posts.id) as posts_count,sum(posts.comments_count) as comments_count,sum(posts.forward_posts_count) as forward_posts_count,sum(posts.favorite_posts_count) as favorite_posts_count'
    @users = ::User.find(:all,:limit=>1000,:select=>select_str,:conditions=>['posts.created_at > ? and posts.created_at < ?',@date1,@date2+1],:group=>'posts.user_id',:order=>'posts_count desc',:joins=>join_str)
    render :layout=>'data_reports'
  end
  
  def tags_count
    #    @title = "晒品统计-话题量统计表"
    render :action=>"data"
  end
  
  def cc_report_tags_count
    return render_404 unless @mms_user
    search = ::User.new(params[:search])
    @date1 = search.created_at.to_date
    @date2 = search.last_login_at.to_date
    join_str = "inner join posts on posts.tag_id = tags.id"
    select_str = 'tags.*,count(posts.id) as posts_count'
    @tags = Tag.find(:all,:limit=>1000,:select=>select_str,:conditions=>['posts.created_at > ? and posts.created_at < ?',@date1,@date2+1],:group=>'posts.tag_id',:order=>'posts_count desc',:joins=>join_str)
    render :layout=>'data_reports'
  end
  
  #这个将会改为在线用户
  def unlogin_users
    render :action=>"data"
  end
  
  def cc_report_login_users
    return render_404 unless @mms_user
    search = ::User.new(params[:search])
    @date1 = search.created_at.to_date
    @date2 = search.last_login_at.to_date
    @users = ::User.find(:all,:limit=>5000,:conditions=>['tp>0 and (last_login_at > ? and last_login_at < ?) and (created_at < ?)',@date1,@date2+1,@date1],:include=>[:industry,:province,:city],:order=>'last_login_at desc')
    render :layout=>'data_reports'
  end
  
  def vip_users
    @title = "用户分析-天使妈爸一览表"
    render :action=>"data"
  end
  
  def cc_report_vip_users
    return render_404 unless @mms_user
    search = ::User.new(params[:search])
    @date = search.created_at.to_date
    conditions = ['users.tp=2 or users.tp=4']
    conditions = ['(users.tp=2 or users.tp=4) and users.name like ?',"%#{search.name}%"] if search.name.present?
    @users = ::User.find(:all,:limit=>1000,:conditions=>conditions,:include=>[:industry,:province,:city],:order=>'last_login_at asc')
    user_ids = @users.collect{|user| user.id  }
    @posts = Post.find(:all,:select=>'created_at,user_id,forward_post_id',:conditions=>['user_id in (?) and created_at > ? and created_at < ?',user_ids,@date-28,@date])
    @comments = Comment.find(:all,:select=>'created_at,user_id',:conditions=>['user_id in (?) and created_at > ? and created_at < ?',user_ids,@date-28,@date])
    @user_datas = []
    @users.each do |user|
      date_counts = []
       ((@date-28)..@date).each do |date|
        date_counts << {:date=>date,:posts_count=>0,:comments_count=>0,:forwards_count=>0}
      end
      @user_datas << {:user=>user,:date_counts=>date_counts} 
    end
    
    @posts.each do |post|
      @user_datas.each do |user_data|
        if post.user_id == user_data[:user].id
          user_data[:date_counts].each do |date_count|
            date_count[:posts_count] += 1 if date_count[:date] == post.created_at.to_date
            date_count[:forwards_count] += 1 if date_count[:date] == post.created_at.to_date and post.forward_post_id.present?
          end
        end
      end
    end
    
    @comments.each do |comment|
      @user_datas.each do |user_data|
        if comment.user_id == user_data[:user].id
          user_data[:date_counts].each do |date_count|
            date_count[:comments_count] += 1 if date_count[:date] == comment.created_at.to_date
          end
        end
      end
    end
    
    render :layout=>'data_reports'
  end
  
  def users_tree
    @title = "用户分析-用户邀请链"
    render :action=>"data"
  end
  
  def cc_report_users_tree
    return render_404 unless @mms_user
    search = ::User.new(params[:search])
    @search_user = ::User.find_by_name(search.name)
    if @search_user.blank?
      render :text=>'no user' and return false
    end
    render :layout=>'data_reports'
  end
  
  def user_posts_chart
    @title = "晒品统计-产品趋势图"
    render :action=>"data"
  end
  
  def cc_report_user_posts_chart
    return render_404 unless @mms_user
    search = ::User.new(params[:search])
    today = Date.today
    unless search.name.blank? 
      @search_user = ::User.find_by_name(search.name)
      if @search_user.blank?
        render :text=>'no user' and return false
      end
    end
    
    @posts_count_labels = []
    
    @posts_counts = []
    @posts_count_datas = []
    
    @comments_counts = []
    @comments_count_datas = []
    
    @forwards_counts = []
    @forwards_count_datas = []
    
    @favorites_counts = []
    @favorites_count_datas = []
    
    @day = search.tp
    
    for i in 0..12
      if @search_user
        conditions = ['user_id=? and created_at < ? and created_at >?',@search_user.id,today-@day*i,today-@day*(i+1)]
      else
        conditions = ['created_at < ? and created_at >?',today-@day*i,today-@day*(i+1)]
      end 
      @posts_count_labels << i
      @posts_counts << Post.count(:all,:conditions=>conditions)
      @comments_counts << Post.sum('comments_count',:conditions=>conditions)
      @forwards_counts << Post.sum('forward_posts_count',:conditions=>conditions)
      @favorites_counts << Post.sum('favorite_posts_count',:conditions=>conditions)
    end
    @posts_counts.reverse!
    @comments_counts.reverse!
    @forwards_counts.reverse!
    @favorites_counts.reverse!
    i = 0
    @posts_count_labels.each do |label|
      @posts_count_datas << "t#{@posts_counts[i]},000000,0,#{label},12"
      @comments_count_datas << "t#{@comments_counts[i]},000000,0,#{label},12"
      @forwards_count_datas << "t#{@forwards_counts[i]},000000,0,#{label},12"
      @favorites_count_datas << "t#{@favorites_counts[i]},000000,0,#{label},12"
      i+=1
    end
    @posts_count_labels.reverse!
    render :layout=>'data_reports'
  end

  def users_count
    render :text=>::User.count
  end

  def posts_count 
    render :text=>Post.count
  end
end
