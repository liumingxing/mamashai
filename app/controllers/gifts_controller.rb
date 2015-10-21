class GiftsController < ApplicationController
  before_filter :need_login_user,:need_login_name_user
  before_filter :get_follow_user_ids
  before_filter :get_space_user
  layout 'space'
  
   
  def index
    @gift_gets = GiftGet.find_user_gift_gets(@space_user,params)
    
    @gifts = Gift.find_normal_gifts
    @gift_get = GiftGet.new
    @gift_get.gift_id = @gifts[0].id if @gifts.present?
    if params[:id]
      user = User.find(params[:id])
      @gift_get.user_name = user.name
    end
  end
  
  def new
    @gift_get = GiftGet.new
    @gift_get.gift_id = @gifts[0].id if @gifts.present?
    if params[:id]
      user = User.find(params[:id])
      @gift_get.user_name = user.name
    end
  end
  
  def sent
    @gift_gets = GiftGet.find_user_gift_sents(@space_user, params)
    
    @gifts = Gift.find_normal_gifts
    @gift_get = GiftGet.new
    @gift_get.gift_id = @gifts[0].id if @gifts.present?
    if params[:id]
      user = User.find(params[:id])
      @gift_get.user_name = user.name
    end
    render :action=>'index'
  end
  
  def birthday
    @gifts = Gift.find_normal_gifts
    @gift_get = GiftGet.new
    @gift_get.gift_id = @gifts[0].id if @gifts.present?
    if params[:id]
      user = User.find(params[:id])
      @gift_get.user_name = user.name
    end
  end
  
  def give_gifts
    redirect_to :action=>"index", :id=>params[:id]
    return
  end
  
  def create_gift_get
    @gift_get = GiftGet.create_user_gift_gets(@user, params)
    unless @gift_get.errors.empty?
      @gifts = Gift.find_normal_gifts
      @gift_gets = GiftGet.find_user_gift_sents(@user,params)
    end
    flash[:notice] = "礼物成功送出"
    redirect_to "/users/#{@space_user.id}/gifts?t=succ" and return
  end
  
  def hide_gift_sent
    @gift_get = GiftGet.find_by_id_and_user_id(params[:id],@user.id)
    @gift_get.is_send_hide = true
    @gift_get.save
    redirect_to :action=>'sent', :anchor=>"n"
  end
  
  def hide_gift_get
    @gift_get = GiftGet.find_by_id_and_send_user_id(params[:id],@user.id)
    @gift_get.is_get_hide = true
    @gift_get.save
    redirect_to :action=>'index'
  end
  
private
  def get_space_user
    @space_user = User.find(params[:user_id]||session[:uid])
    @is_me = (@user and @user.id == @space_user.id)
  end
  
end
