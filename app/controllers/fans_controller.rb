class FansController < ApplicationController 
  before_filter :need_login_user,:need_login_name_user
  before_filter :get_space_user
  layout "space"
  
  def index
    MamashaiTools::ToolUtil.clear_unread_infos(@user,:unread_fans_count)
    @fans = @space_user.fans.paginate(:total_entries=>@user.fans_users_count, :page=>params[:page]||1,:include=>[:province,:city,:last_post,:first_kid],:order=>"follow_users.id desc",:per_page=>25)
    if params.keys.include?("home")
      render :action=>'users'
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
    @fans = @space_user.fans.paginate(:page=>params[:page]||1,:include=>[:province,:city,:last_post,:first_kid],
                                      :conditions=>["users.age_id=?",@age.id] ,:order=>"follow_users.id desc", :per_page=>25)
    render :action=>'users'
  end
  
  def group_by_group
    @groups = @user.fans_groups
    @group = FansGroup.find(params[:group]) if params[:group].present?
    if @group
      @fans = @space_user.fans.paginate(:page=>params[:page]||1,:include=>[:province,:city,:last_post,:first_kid],
                                        :conditions=> ["follow_users.fans_group_id=?",@group.id] ,:order=>"follow_users.id desc", :per_page=>25)
    else
      @fans = @space_user.fans.paginate(:page=>params[:page]||1,:include=>[:province,:city,:last_post,:first_kid],
                                        :conditions=> ["follow_users.fans_group_id is null"],:order=>"follow_users.id desc", :per_page=>25)
    end
    render :action=>'users'
  end 
  
  def search
    @search_user = User.new(params[:search_user])
    @keyword = @search_user.name
    @fans = @space_user.fans.paginate(:page=>params[:page]||1,:include=>[:province,:city,:last_post,:first_kid],
                                      :conditions=>["users.name like ?","%#{@keyword}%"] ,:order=>"follow_users.id desc", :per_page=>25)
    render :action=>'users'
  end 
  
  def edit_group
    @fans = User.find(params[:id])
    @groups = @user.fans_groups
    follow_user = FollowUser.find_by_follow_user_id_and_user_id(@user.id,@fans.id)
    @group = follow_user.fans_group if follow_user
    render :layout=>false
  end
  
  def update_group
    @fans = User.find(params[:id])
    @group = FansGroup.find(params[:group][:id]) if params[:group][:id].present? 
    ActiveRecord::Base.transaction do 
      @group = FansGroup.find_or_create_by_name_and_user_id(:name => params[:group][:name],:user_id=>@user.id) if params[:group][:name].present?
      if @group
        follow_user = FollowUser.find_by_follow_user_id_and_user_id(@user.id,@fans.id)
        old_group_id=follow_user.fans_group_id
        follow_user.update_attributes(:fans_group_id=>@group.id,:fans_remark=>@group.name) if follow_user
        FansGroup.update_all("users_count=(select count(*) from follow_users where fans_group_id=#{@group.id})","id=#{@group.id}")
        FansGroup.update_all("users_count=(select count(*) from follow_users where fans_group_id=#{old_group_id})","id=#{old_group_id}") if old_group_id
      end
    end
    render :layout=>false
  end
  
  def edit_nick_name
    @fans = User.find(params[:id])
    @follow_user = FollowUser.find_one_follow_user(@fans,@user)
    render :layout=>false
  end
  
  def update_nick_name
    @fans = User.find(params[:id])
    @follow_user = FollowUser.find_one_follow_user(@fans,@user)
    @follow_user.update_attributes(params[:follow_user])
    render :layout=>false
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
