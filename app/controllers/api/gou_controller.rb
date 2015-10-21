require 'open-uri'
require 'nokogiri'

class Api::GouController < Api::ApplicationController
	before_filter :authenticate!, :only=>%w(get_addresses add_address set_default_address delete_address create_order my_order fav delete_order receive_order make_comment)
	
	#获得首屏的爆款，及4个类目的简介，本周超值组合推荐
	def introduce
		render :json => Rails.cache.fetch("gou_main", :expires_in=>1.minutes){
	      baokuans = ABaokuan.all(:conditions=>"stop_at > '#{Time.new.to_s(:db)}'", :order=>"begin_at")
		  categories = ACategory.all(:order=>"position")
		  wait = Time.new.to_s(:db) < "2015-05-20 10:00:00"
		  #wait = false
		  {:baokuan => baokuans, :categories=>categories, :wait=>wait}.to_json
	    }
	end

	#获得某一个类别的商品
	def products_of
		if params[:category_id] == "0"
			products = AProduct.paginate(:page=>params[:page], :per_page=>params[:per_page]||10, :conditions=>"hide=0 and for_age like '%#{params[:title]}%'", :order=>"category_id desc, position desc, id desc")
		else
			products = AProduct.paginate(:page=>params[:page], :per_page=>params[:per_page]||10, :conditions=>"hide=0 and category_id = #{params[:category_id]}", :order=>"position desc, id desc")
		end
		render :json=>products
	end

	#获得某一个商品的详情
	def detail_of
		product = AProduct.find(params[:id])
		render :json=>product.to_json({:only=>%w(remark introduce detail), :methods=>%w(logos)})

#		render :json=>Rails::cache.fetch("product_detail_of_#{params[:id]}", :expires=>2.hours){
#			product = AProduct.find(params[:id])
#			product.to_json({:only=>%w(remark introduce detail), :methods=>%w(logos)})
#		}
	end

	#某人获得所有地址
	def get_addresses
		address = AAddress.all(:conditions=>["user_id = ?", @user.id])
		render :json=>address
	end

	#添加或修改地址
	def add_address
		if params[:receiver].to_s.size == 0
			render :json=>{:error=>"请输入收件人"} and return
		end

		if params[:mobile].to_s.size == 0
			render :json=>{:error=>"请输入联系电话"} and return
		end

		if params[:city].to_s.size == 0
			render :json=>{:error=>"请选择所在城市"} and return
		end

		if params[:address].to_s.size < 4
			render :json=>{:error=>"请填写详细地址，具体到门牌号"} and return
		end

		address = AAddress.find_by_id(params[:id])
		address = AAddress.new if !address
		address.user_id = @user.id
		address.receiver = params[:receiver]
		address.mobile = params[:mobile]
		address.city = params[:city]
		address.address = params[:address]
		address.default = (params[:default] == "yes")
		if params[:default] == "yes"
			AAddress.update_all("`default`=0", ["user_id=?", @user.id])
		end
		address.id_code = params[:id_code] if params[:id_code]
		address.id_name = params[:id_name] if params[:id_name]
		address.id_logo1 = params[:id_logo1] if params[:id_logo1]
		address.id_logo2 = params[:id_logo2] if params[:id_logo2]
		if address.save
			render :json=>address
		else
			render :json=>{:error=>"对不起，保存地址出错"}
		end
	end

	#设置默认地址
	def set_default_address
		address = AAddress.find_by_id(params[:id])
		if address.user_id == @user.id
			AAddress.update_all("default=0", ["user_id=?", @user.id])
			address.default = true
			address.save
		else
			render :json=>{:error=>"对不起，设置默认地址出错"}	
		end
	end

	#删除地址
	def delete_address
		address = AAddress.find_by_id(params[:id])
		if address.user_id == @user.id
			address.destroy
			render :text=>"ok"
		else
			render :text=>"error"
		end
	end

	#获得收藏的商品
	def fav
		favs = Favourite.paginate(:conditions=>["user_id = ? and tp = 'gou'", @user.id], :order=>"id desc", :page=>params[:page], :per_page=>10, :total_entries=>100)
		ids = favs.map{|f| f.tp_id} << -1
		@products = AProduct.all(:conditions=>"id in (#{ids.join(',')})")
		render :json=>@products
	end

	#获得已提交的订单
	def my_order
		orders = AOrder.all(:conditions=>["is_hide = 0 and user_id = ?", @user.id], :order=>"id desc")
		render :json=>orders
		#render :json=>orders.to_json({:include=>{:address=>{:only=>AAddress.json_attrs}, :details=>{:methods=>%w(name logo)}}})
	end

	#获得某个订单
	def order_of
		order = AOrder.find_by_id(params[:id])
		render :json=>order
		#render :json=>order.to_json({:include=>{:address=>{:only=>AAddress.json_attrs}, :details=>{:methods=>%w(name logo)}}})
	end

	#提交订单
	def create_order
		#检查订单合法性

		#开启事物
		ActiveRecord::Base.transaction do
			order = AOrder.new
			order.user_id = @user.id
			order.address_id = params[:address_id]
			order.price = params[:price]
			order.o_price = params[:o_price]
			order.score_amount = params[:score_amount]
			order.vip_amount = params[:vip_amount]
			order.vip_code   = params[:vip_code]
			order.redpacket_id = params[:redpacket_id]
			order.yunfee = params[:yunfee]
			order.payment = params[:payment]
			order.paymethods = params[:paymethods]
			order.save

			details = ActiveSupport::JSON.decode(params[:details])
			for detail in details
				product = AProduct.find_by_id(detail["product_id"])
				render :json=>{:result=>"error", :desc=>"找不到产品"} and return if !product
				if product.hide
					order.destroy
					render :json=>{:result=>"error", :desc=>"对不起，#{product.name}已经下架了"}
					return 
				end

				if product.is_baokuan
					Rails::cache.delete("product_detail_of_#{product.id}")

					baokuan = ABaokuan.find_by_a_product_id(product.id)
					if AOrderDetail.sum(:count, :conditions=>"a_product_id = #{product.id} and a_orders.status = '待发货'", :joins=>"left join a_orders on a_orders.id = a_order_details.a_order_id") >= baokuan.count
						render :json=>{:result=>"error", :desc=>"对不起，#{product.name}都抢完了"} and return 
					end
				end

				order_detail = AOrderDetail.new
				order_detail.a_order_id = order.id
				order_detail.a_product_id = detail["product_id"]
				order_detail.price = detail["price"]
				order_detail.o_price = detail["o_price"]
				order_detail.count = detail["count"]
				if !order_detail.save
					txt = ''
					order_detail.errors.each{|attr, msg| txt << msg}
					render :json=>{:result=>"error", :desc=>txt, :id=>order.id} and return 
				end
			end
			render :json=>{:result=>"ok", :desc=>"保存订单成功", :id=>order.id} and return 
		end
		render :json=>{:result=>"error", :desc=>"保存订单发生错误", :id=>order.id} and return 
	end

	def notify_url2
		order = AOrder.find_by_id(params[:out_trade_no])
		if order && order.status == "待付款" && (params[:trade_status] == "TRADE_FINISHED" || params[:trade_status] == "TRADE_SUCCESS")
			order.status = "待发货"
			order.pay_at = Time.new
			order.save

			if order.score_amount > 0
				Mms::Score.trigger_event(:zhiyou_score, "直邮商品晒豆抵现", 0-order.score_amount*10, 1, {:user => order.user, :description=>"直邮商品晒豆抵现"})
			end

			MamashaiTools::ToolUtil.push_aps(order.user_id, "亲，您的订单付款成功，请等待发货！");
		end
		payment = APayment.find_by_order_id(params[:out_trade_no])
		payment = APayment.new if !payment
		payment.order_id = params[:out_trade_no]
		payment.trade_no = params[:trade_no]
		payment.buyer_email = params[:buyer_email]
		payment.buyer_id = params[:buyer_id]
		payment.price = params[:price]
		payment.subject = params[:subject]
		payment.status = params[:trade_status]
		payment.seller_email = params[:seller_email]
		payment.notify_id = params[:notify_id]
		payment.use_coupon = params[:use_coupon]
		payment.save
		render :text=>"ok"
	end

	def notify_url
		text = params[:notify_data]
		text.scan(/<trade_status>(\w+)<\/trade_status>/)
		if $1 == "TRADE_FINISHED" || $1 == "TRADE_SUCCESS"
			text.scan(/<out_trade_no>(\d+)<\/out_trade_no>/)
			order = AOrder.find_by_id($1)
			if order.status == "待付款"
				if order
					order.status = "待发货"
					order.pay_at = Time.new
					order.save
				end
			end
		end

		payment = APayment.find_by_order_id($1)
		payment = APayment.new if !payment;
		payment.order_id = $1
		text.scan(/<trade_no>(\w+)<\/trade_no>/)
		payment.trade_no = $1
		text.scan(/<buyer_email>([\w\W]+)<\/buyer_email>/)
		payment.buyer_email = $1
		text.scan(/<buyer_id>([\w\W]+)<\/buyer_id>/)
		payment.buyer_id = $1
		text.scan(/<price>([\w\W]+)<\/price>/)
		payment.price = $1
		text.scan(/<subject>([\w\W]+)<\/subject>/)
		payment.subject = $1
		text.scan(/<trade_status>(\w+)<\/trade_status>/)
		payment.status = $1
		text.scan(/<seller_email>([\w\W]+)<\/seller_email>/)
		payment.seller_email = $1
		text.scan(/<notify_id>(\w+)<\/notify_id>/)
		payment.notify_id = $1
		text.scan(/<use_coupon>(\w+)<\/use_coupon>/)
		payment.use_coupon = $1
		payment.save
		render :text=>"您向妈妈晒付款成功"
	end

	def callback_url
		order = AOrder.find_by_id(params[:out_trade_no])
		if params[:result] == "success"
			order.status = "待发货"
			order.pay_at = Time.new
			order.save

			if order.score_amount > 0
				Mms::Score.trigger_event(:zhiyou_score, "直邮商品晒豆抵现", -order.score_amount*10, 1, {:user => order.user, :description=>"直邮商品晒豆抵现"})
			end
		end
		
		if params[:result] == "success"
			MamashaiTools::ToolUtil.push_aps(order.user_id, "亲，您的订单付款成功，请等待发货！");
			render :text=>'<html><meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" /><body><p>付款成功，请等待发货！</p></body></html>'
		else
			render :text=>'<html><meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" /><body><p>抱歉，付款失败了</p></body></html>'
		end
	end

	def interrupt_url
		render :text=>'<html><meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" /><body><p>抱歉，付款过程中出现了问题</p></body></html>'
	end

	def delete_order
		order = AOrder.find_by_id(params[:id])
		if !order
			render :json=>{"desc"=>"找不到此订单", "code"=>-1}
		else
			if order.user_id != @user.id
				render :json=>{"desc"=>"没有删除此订单的权限", "code"=>-1}
			end
			order.is_hide = true
			order.save
			render :json=>{"desc"=>"删除订单成功", "code"=>0}
		end
	end

	def receive_order
		order = AOrder.find_by_id(params[:id])
		if !order
			render :json=>{"desc"=>"找不到此订单", "code"=>-1}
		else
			if order.user_id != @user.id
				render :json=>{"desc"=>"您没有此订单的权限", "code"=>-1}
			end
			order.status = "已收货"
			order.save
			render :json=>{"desc"=>"感谢您的回馈", "code"=>0}
		end
	end

	def make_comment
		order = AOrder.find(params[:id])
		for detail in order.details
			comment = AComment.new
			comment.a_order_id = order.id
			comment.a_order_detail_id = detail.id
			comment.a_product_id = detail.a_product_id
			comment.user_id = @user.id
			comment.text = params["comment_txt_#{detail.a_product_id}"]
			comment.star = params["comment_star_#{detail.a_product_id}"]
			comment.save

			Rails::cache.delete("product_detail_of_#{detail.a_product_id}")

			0.upto(4) do |i|
				logger.info "comment_logo_#{detail.a_product_id}_#{i}"
				logger.info params["comment_logo_#{detail.a_product_id}_#{i}"].class
				next if params["comment_logo_#{detail.a_product_id}_#{i}"].class == String
				
				logo = ACommentLogo.new
				logo.a_product_id = detail.a_product_id
				logo.a_comment_id = comment.id
				logo.user_id = @user.id
				logo.logo = params["comment_logo_#{detail.a_product_id}_#{i}"]
				logo.save
			end
		end
		order.status = "已评价"
		order.save
		Mms::Score.trigger_event(:zhiyou_comment, "评价商品", 10*order.details.size, 1, {:user => order.user})
		
		render :json=>{:code=>0, :desc=>"提交评价成功"}
	end

	def get_comment
		comments = AComment.all(:conditions=>["a_product_id = ?", params[:product_id]], :order=>"id desc", :limit=>5)
		count = AComment.count(:conditions=>["a_product_id = ?", params[:product_id]])
		if count > 0
			star = (AComment.sum(:star, :conditions=>["a_product_id = ?", params[:product_id]])*1.0/count).round
		else 
			star = 5
		end
		render :json=>{:count=>count, :comments=>comments, :star=>star}
	end

	def check_vip
		vip = AVip.find_by_code(params[:code])
		render :text=>vip ? "yes" : "no"
	end

	def check_sn
		pre = %!<html>
<head>
	<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
</head>
<style>
* {font-size: 1em;}
td {padding: 0.5em;}
tr td{border-bottom: 1px solid #ccc;}

</style>
<body>
<table style="border-collapse: collapse">!
		render :text=>pre + Nokogiri::HTML(open("http://www.auexpress.com.au/TOrderQuery.aspx?OrderId=#{params[:id]}")).css("#ctl00_ContentPlaceHolder1_dg table tr td table tbody")[1].css("tr td div table tr").to_s + "</table></body></html>"
	end
end
