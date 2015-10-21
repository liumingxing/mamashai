class SpaceController < ApplicationController
  before_filter :get_login_user
  before_filter :get_follow_user_ids
  
  layout "space"
  
  def post
    redirect_to :controller=>"account", :action=>"login" and return if !@user
    
    @post = Post.find_by_id(params[:id])
    redirect_to "/" and return if !@post
    redirect_to "/articles/article/#{@post.from_id}" and return if @post.from == "article"
    @space_user = @post.user if @post
    
    redirect_to "/404.html" if !@post
  end
  
  def user
    @space_user = User.find_decrypt_user(params[:id])
    if !@user
      redirect_to :controller=>"p", :action=>"index" and return
    end

    if !@user && !params[:page].blank?
      redirect_to :action=>'signup',:controller=>'account',:id=>@space_user.id and return false
    end
    
    if params[:tp] == "ilike"
      @posts = Post.not_hide.paginate(:page=>params[:page], :per_page=>params[:per_page], 
        :conditions=>"claps.tp = 'post' and claps.user_id = #{@space_user.id}", 
        :order=>"id desc", 
        :group=>"posts.id", 
        :joins=>"left join claps on claps.tp_id = posts.id")
    elsif params[:tp] == "like"
      @posts = Post.not_hide.paginate(:page=>params[:page], :per_page=>params[:per_page], 
        :conditions=>"claps.tp = 'post' and posts.user_id = #{@space_user.id}", 
        :order=>"id desc", 
        :group=>"posts.id", 
        :joins=>"left join claps on claps.tp_id = posts.id")
    else
      #@posts = Post.search '', :with=>{:user_id=>@space_user.id, :is_private=>false, :is_hide=>false}, :order=>"created_at desc",:page=>params[:page], :per_page=>20
      
      conditions = ["user_id = #{@space_user.id}"]
      if @user && @user.id != @space_user.id
        conditions << "is_private = 0"
      end
      @posts = Post.not_hide.paginate(:page=>params[:page], :per_page=>params[:per_page], :conditions=>conditions.join(' and '), :order=>"id desc")
    end
      
      
    
    @space_user.create_visit_user(@user) if @user and @space_user.id != @user.id
  end  

  def user_domain
    @space_user = User.find_by_domain(params[:id])

    if !@user && !params[:page].blank?
      redirect_to :action=>'signup',:controller=>'account',:id=>@space_user.id and return false
    end
    
    if params[:tp] == "bbrl"
      @posts = Post.bbrl.paginate :page=>params[:page], :per_page=>params[:per_page], :conditions=>"user_id = #{@space_user.id}", :order=>"id desc"
    elsif params[:tp] == "lmrb"
      @posts = Post.lmrb.paginate :page=>params[:page], :per_page=>params[:per_page], :conditions=>"user_id = #{@space_user.id}", :order=>"id desc"
    elsif params[:tp] == "ilike"
      @posts = Post.not_hide.paginate(:page=>params[:page], :per_page=>params[:per_page], 
        :conditions=>"claps.tp = 'post' and claps.user_id = #{@space_user.id}", 
        :order=>"id desc", 
        :group=>"posts.id", 
        :joins=>"left join claps on claps.tp_id = posts.id")
    elsif params[:tp] == "like"
      @posts = Post.not_hide.paginate(:page=>params[:page], :per_page=>params[:per_page], 
        :conditions=>"claps.tp = 'post' and posts.user_id = #{@space_user.id}", 
        :order=>"id desc", 
        :group=>"posts.id", 
        :joins=>"left join claps on claps.tp_id = posts.id")
    else
      @posts = Post.not_hide.paginate(:page=>params[:page], :per_page=>params[:per_page], :conditions=>"user_id = #{@space_user.id}", :order=>"id desc")
    end
      
      
    
    @space_user.create_visit_user(@user) if @user and @space_user.id != @user.id

    render :action=>:user
  end
end
