# -*- coding: utf-8 -*-
class Mms::TuanOrdersController <  Mms::MmsBackEndController
  def index
    @cond = params[:cond] || ""
    conditions = (['state = ?', @cond] unless @cond.blank? ) || ['state IS NOT NULL']
    page =  params[:page] || 1
    @orders = TuanOrder.paginate :page =>page, :per_page =>30, :conditions =>  conditions, :order=>"created_at desc"
  end
  
  def search
    keyword = params[:keyword]
    page =  params[:page] || 1
    user = ::User.first(:conditions => ['email = ? or name = ?', keyword, keyword])
    user_id = (user.id unless user.blank?) || 0
    @orders = TuanOrder.paginate :page =>page, :per_page =>30, :conditions =>  ['id = ? or user_id = ?', TuanOrder.get_order_id(keyword), user_id], :order => 'id DESC'
    render :action => :index
  end
  
  def update
    order = TuanOrder.update(params[:id], params[:order].merge({:operator => "妈妈晒客服"}))
    order.fire_events(params[:order][:state].to_sym)
    redirect_to :action => :show, :id => order.id
  end
  
  def show
    @order = TuanOrder.find(params[:id])
  end
  
  def address_edit
    @order = TuanOrder.find(params[:id])
  end
  
  def address_update
    order = TuanOrder.find(params[:id])
    order.receiver_name = params[:receiver_name]
    order.info[:receiver_province_id] = params[:info][:receiver_province_id]
    order.info[:city_id] = params[:info][:city_id]
    order.receiver_address = params[:receiver_address]
    order.info[:receiver_post_code] = params[:info][:receiver_post_code]
    order.receiver_mobile= params[:receiver_mobile]    
    order.info[:phone] = params[:info][:phone].select{|k,v| !v.blank?}.collect{|k,v| v}.join('-') if params[:info][:phone]
    order.info[:email] = params[:info][:email]
    order.info[:memo] = params[:info][:memo]
    order.note = params[:note]
    if order.save
      OrderLog.create :log=>"修改订单信息", :user_name => @mms_user.username ,:order_id=> order.id,:tp=>1, :note=> order.note
    end
    redirect_to :action => "show", :id => order.id
  end
  
  #ToDo
  def tuan_order
    @cond = params[:cond] || ""
    cond = []
    if @cond.blank?
      cond << ['state IS NOT NULL']
    else
      cond << ['state = ?', @cond] 
    end
    page =  params[:page] || 1
    @orders = TuanOrder.paginate :page =>page, :per_page =>30, :conditions => TuanOrder.merge_conditions(*cond), :order=>"created_at desc"
  end
  
  def expired
    page =  params[:page] || 1
    @order_items = OrderItem.all(:conditions=>["tuans.end_time < ? and orders.state=? and orders.type=?",Time.now,'new_order','TuanOrder'],:joins=>"inner join tuans on order_items.item_id=tuans.id",:include=>[:order])
    @orders = @order_items.map(&:order).paginate :page =>page, :per_page =>30
  end
  
  def expired_action
    @order_ids = params[:order_ids].collect{|m| m[0] if m[1]=='1'}.compact
    if @order_ids.blank?
      flash[:notice]="请先选择订单后再提交" 
    else
      Order.find(@order_ids).each do |order|
        order.operator = '系统'
        order.expired
      end
      flash[:notice]="操作成功"
    end
    redirect_to :action => :expired
  end
  
end
