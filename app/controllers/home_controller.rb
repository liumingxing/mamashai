class HomeController < ApplicationController
  before_filter :need_login_user,:need_login_name_user
  before_filter :get_space_user
  before_filter :get_follow_user_ids
  layout "space"
  
  def index
    params[:user] = @user
    params[:post_tp] ||= "my"
    params[:from] ||= "my"
    if params[:from] == "like"
      @posts = Post.not_hide.paginate(:page=>params[:page], :per_page=>params[:per_page], 
        :conditions=>"claps.tp = 'post' and claps.user_id = #{@user.id}",
        :order=>"id desc", 
        :group=>"posts.id",
        :joins=>"left join claps on claps.tp_id = posts.id")
    else
      @posts = Post.find_all_posts(params)
      #@posts = Post.search '', :with=>{:is_hide=>false, :user_id => @user.id}, :order=>"created_at desc", :page=>params[:page], :per_page=>20
    end
    @record_day = Date.today
    @record_day = Date.parse(params[:date]) if params[:date]
  end
  
  def atme
    MamashaiTools::ToolUtil.clear_unread_infos(@user,:unread_atme_count)
    @reminds = AtRemind.paginate :page=>params[:page], :per_page=>25, :conditions=>"user_id=#{@user.id}", :order=>"id desc"
    @posts = Post.find(:all, :order=>"id desc", :conditions=>"id in (#{(@reminds.map{|r| r.post_id}<<-1).join(',')})")
  end
  
  def comments
    MamashaiTools::ToolUtil.clear_unread_infos(@user, :unread_comments_count)
    @reminds = CommentAtRemind.paginate :page=>params[:page], :per_page=>25, :conditions=>"tp='comment' and user_id=#{@user.id}", :order=>"id desc"
    @comments = Comment.find(:all, :order=>"id desc", :conditions=>"id in (#{(@reminds.map{|r| r.comment_id}<<-1).join(',')})")
  end
  
  def comments_send
    @comments = Comment.find_user_comments(@user,params)
    @reminds = @comments
    render :action=>'comments'
  end
  
  def like
    @posts = Post.not_hide.paginate(:page=>params[:page], :per_page=>params[:per_page], 
        :conditions=>"claps.tp = 'post' and posts.user_id = #{@space_user.id}", 
        :order=>"id desc", 
        :group=>"posts.id", 
        :joins=>"left join claps on claps.tp_id = posts.id")
    MamashaiTools::ToolUtil.clear_unread_infos(@user, "unread_favorites_count")
    @reminds = @posts
    render :action=>"atme"
  end
  
  def messages
    @message_topics = MessageTopic.find_message_topics(@user,params)
  end
  
  def message_topic
    @message_topic = MessageTopic.find(params[:id])
    @message_posts = @message_topic.find_message_posts(params)
  end
  
  def delete_message_topic
    message = MessageTopic.find_by_id_and_user_id(params[:id],@user.id)
    message.destroy if message
    redirect_to :action=>'messages'
  end
  
  def delete_message_post
    message_post = MessagePost.find_by_id(params[:id])
    return render_404 unless message_post
    return render_404 if message_post.message_user_id != @user.id and message_post.user_id != @user.id
    @message_topic = MessageTopic.find(message_post.message_topic_id)
    message_post.destroy
    @message_topic.last_message_post = MessagePost.find(:first,:conditions=>['message_topic_id = ?',@message_topic.id],:order=>'id desc')
    @message_topic.save
    redirect_to :action=>'message_topic',:id=>@message_topic.id
  end
  
  def follows_comments
    @comments = Comment.find_user_posts_follows_comments(@user,params)
    render :action=>'comments'
  end
  
  def other_comments
    @comments = Comment.find_user_posts_other_comments(@user,params)
    render :action=>'comments'
  end
  
  def create_comment
    if Blockname.find_by_user_id(@user.id)
      redirect_to :action=>'post',:controller=>'space',:id=>@post.id and return
    end
    
    flash[:comment_error] = ''
    @post = Post.find(params[:id])
    @comment = Comment.create_comment(params,@user,@post)
    unless @comment.errors.empty?
      @comment.errors.each{|attr,msg| flash[:comment_error] << msg }
    end
    
    redirect_to :action=>'post',:controller=>'space',:id=>@post.id
  end
  
  def delete_select_comments
    comment_ids = params[:comment_ids].split(',')
    unless comment_ids.blank?
      Comment.delete_all_select_comments(comment_ids,@user)
    end
    redirect_to :action=>params[:back_action]
  end
  
  def create_post
    return render_404 if params[:post].blank?
    @post = Post.create_post(params,@user)
    if !@post.errors.empty?
      errors = []
      @post.errors.each do |attribute, errors_array|
        errors << errors_array
      end
      flash[:error] = errors.join(",")
      redirect_to params[:back] || '/home/index?error=true' and return false 
    else
      flash[:notice] = "记录发布成功"
    end    
    #@post.save_to_sina if params[:to_weibo]
    redirect_to params[:back] || '/home/index'
  end
  
private  
  def get_space_user
    @space_user = User.find(session[:uid])
  end
end
