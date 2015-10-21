module TuanHelper
  
  def link_to_tuan_website(tuan)
    return if tuan.blank?
    link_to "【"+tuan.tuan_website.name+"】","/tuan/go_url/#{tuan.tuan_website_id}",:title=>tuan.tuan_website.name,:class=>"web_name", :target=>"_blank"
  end
    
  def order_state(order)
    case order.state
      when "new_order"
        order_operator = link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
        order_operator += tag("br")
        order_operator += link_to "付款", "/balance/bank/#{order.id}"
        order_operator += link_to "取消", "/balance/order_cancled/#{order.id}?tp=#{@tp}", :confirm => '您确定要取消定单吗？', :method => :get 
      when "has_paid"
        link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
      when "has_sent"
        link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
      when "user_canceled"
        link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
      when "sys_canceled"
        link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
      when "user_problem"
        order_operator = link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
        order_operator += tag("br")
        order_operator += link_to "付款", "/balance/bank/#{order.id}"
        order_operator += link_to "取消", "/balance/order_cancled/#{order.id}?tp=#{@tp}", :confirm => '您确定要取消定单吗？', :method => :get
      when "sys_problem"
        order_operator = link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
        order_operator += tag("br")
        order_operator += link_to "付款", "/balance/bank/#{order.id}" 
        order_operator += link_to "取消", "/balance/order_cancled/#{order.id}?tp=#{@tp}", :confirm => '您确定要取消定单吗？', :method => :get
      when "fixed_user_problem"
        order_operator = link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
        order_operator += tag("br")
        order_operator += link_to "付款", "/balance/bank/#{order.id}"
        order_operator += link_to "取消", "/balance/order_cancled/#{order.id}?tp=#{@tp}", :confirm => '您确定要取消定单吗？', :method => :get
      when "fixed_sys_problem"
        order_operator = link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
        order_operator += tag("br")
        order_operator += link_to "付款", "/balance/bank/#{order.id}"
        order_operator += link_to "取消", "/balance/order_cancled/#{order.id}?tp=#{@tp}", :confirm => '您确定要取消定单吗？', :method => :get
      when "has_sign_up"
        order_operator = link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
        order_operator += link_to "确认收到", {:action => "order_received", :id => order.id }
      when "has_received"
        link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
      when "has_closed"
        link_to "查看详情", {:action => :order_details, :id => order.id, :tp => @tp}
    end
  end
  
  def mms_tuan_state(tuan)
    case tuan.tuan_state
    when "未开始"
      link_to '<img src="/images/tuan/shop_button_5.png">', "javascript:void(0);", {:onclick => 'alert("团购未开始！");'}
    when "抢购中"
      if @user and (tuan.tp==2 or tuan.tp==3) and OrderItem.count(:conditions=>["order_items.item_type=? and order_items.item_id=? and orders.user_id=?",'Tuan',tuan.id,@user.id],:joins=>"inner join orders on order_items.order_id=orders.id")>0
          link_to  image_tag("/images/tuan/shop_button_1.png"), "javascript:void(0);",:onclick=>"alert('您已参加此次活动');"
      else
          link_to image_tag("/images/tuan/shop_button_1.png"),:action=>"add_item",:id=>tuan.id
      end
    when "已结束"
      link_to '<img src="/images/tuan/shop_button_2.png">', "javascript:void(0);", {:onclick => 'alert("团购已结束！");'}
    when "已卖光"
      link_to '<img src="/images/tuan/shop_button_3.png">', "javascript:void(0);", {:onclick => 'alert("团购已卖光！");'}
    end
  end
  
  def fetch_city(city_name)
    city_name ||= cookies[:city]
    if city_name and city_name != "全国" and Tuan.cities.include?(city_name)
      return ["address like(?) or address like (?)","%"+city_name+"%","%全国%"]
    else
      return nil
    end
  end
  
  def tuan_grade_labels(comment=nil)
    if comment.present?
      render :partial => 'tuan_grade_labels_comment', :locals => {:comment=>comment}
    else
      render :partial => 'tuan_grade_labels'
    end
  end
  
end
