class FollowsController < ApplicationController 
  before_filter :need_login_user,:need_login_name_user
  before_filter :get_space_user
  layout "space"
  
  def index
    conditions = ["1=1"]
    conditions << "is_fans=1" if params[:tp] == "friends"
    @follows = @space_user.follows.paginate(:page=>params[:page]||1, :conditions=>conditions.join(' and '), :include=>[:province,:city,:last_post,:first_kid],:order=>"follow_users.id desc",:per_page=>25)
    if params.keys.include?("home")
      render :action=>'users', :layout=>"home"
    else
      render :action=>'users'
    end
  end
  
  def group_by_kid_age
    if params[:age].blank?
      @age = Age.find(:first)
    else
      @age = Age.find(params[:age])
    end
    @follows = @space_user.follows.paginate(:page=>params[:page]||1,:include=>[:province,:city,:last_post,:first_kid],
                                            :conditions=>["users.age_id=?",@age.id] ,:order=>"follow_users.id desc", :per_page=>25)
    render :action=>'users'
  end
  
  def group_by_group
    @groups = @user.follows_groups
    @group = FollowsGroup.find(params[:group]) if params[:group].present?   
    if @group
      @follows = @space_user.follows.paginate(:page=>params[:page]||1,:include=>[:province,:city,:last_post,:first_kid],
                                              :conditions=> ["follow_users.follows_group_id=?",@group.id],:order=>"follow_users.id desc", :per_page=>25)
    else
      @follows = @space_user.follows.paginate(:page=>params[:page]||1,:include=>[:province,:city,:last_post,:first_kid],
                                              :conditions=> ["follow_users.follows_group_id is null"],:order=>"follow_users.id desc", :per_page=>25)
    end
    render :action=>'users'
  end 
  
  def search
    @search_user = User.new(params[:search_user])
    @keyword = @search_user.name
    @follows = @space_user.follows.paginate(:page=>params[:page]||1,:include=>[:province,:city,:last_post,:first_kid],
                                            :conditions=>["users.name like ?","%#{@keyword}%"] ,:order=>"follow_users.id desc", :per_page=>25)
    render :action=>'users'
  end
  
  def show
  end
  
  def edit_group
    @follow = User.find(params[:id])
    @groups = @user.follows_groups
    follow_user = FollowUser.find_by_follow_user_id_and_user_id(@follow.id,@user.id)
    @group = follow_user.follows_group if follow_user
    render :layout=>false
  end
  
  def update_group 
    @follow = User.find(params[:id])
    @group = FollowsGroup.find(params[:group][:id]) if params[:group][:id].present? 
    ActiveRecord::Base.transaction do 
      @group = FollowsGroup.find_or_create_by_name_and_user_id(:name => params[:group][:name],:user_id=>@user.id) if params[:group][:name].present? 
      if @group
        follow_user = FollowUser.find_by_follow_user_id_and_user_id(@follow.id,@user.id)
        old_group_id=follow_user.follows_group_id if follow_user
        follow_user.update_attributes(:follows_group_id=>@group.id,:remark=>@group.name) if follow_user
        FollowsGroup.update_all("users_count=(select count(*) from follow_users where follows_group_id=#{@group.id})","id=#{@group.id} ")
        FollowsGroup.update_all("users_count=(select count(*) from follow_users where follows_group_id=#{old_group_id})","id=#{old_group_id} ") if follow_user and old_group_id
      end
    end
    render :layout=>false
  end
  
  def edit_nick_name
    @follow = User.find(params[:id])
    @follow_user = FollowUser.find_one_follow_user(@user,@follow)
    render :layout=>false
  end
  
  def update_nick_name
    @follow = User.find(params[:id])
    @follow_user = FollowUser.find_one_follow_user(@user,@follow)
    @follow_user.update_attributes(params[:follow_user])
    render :layout=>false
  end
  
  def remove_from_group
  end
  
  private
  
  def get_space_user
    @space_user = User.find(params[:user_id])
    @is_me = (@user and @user.id == @space_user.id)
  end
  
  def set_layout
    @is_me ? 'friends' : 'space'
  end
  
end
