class OrderController < ApplicationController
	def notify_add_cash
		render :text=>"对不起，照片书打印服务已停止" and return;

		text = params[:notify_data]
		text.scan(/<trade_status>(\w+)<\/trade_status>/)
		if $1 == "TRADE_FINISHED"
			text.scan(/<out_trade_no>(\d+)<\/out_trade_no>/)
			order = AlbumOrder.find_by_id($1)
			if order.status == "未付款"
				Mms::Score.trigger_event(:buy_album, "制作照片书并下单", 5, 1, {:user => order.user})
				if order
					order.status = "已付款"
					order.pay_at = Time.new
					order.save
				end
			end
		end
		render :text=>"您向妈妈晒付款成功"
	end

	def return_add_cash
		render :text=>"对不起，照片书打印服务已停止" and return;
		
		if params[:result] == "success"
		  order = AlbumOrder.find_by_id(params[:out_trade_no])
	      if order && order.status == "未付款"
	      	order.status = "已付款"
	      	order.save
	      end
	      render :text=>"<h1>支付成功</h1>"
	      return
	    end
	    render :text=>"<h1>支付失败</h1>"
	end

	#用户中途退出
	def merchant
		render :text=>"您终止了付款"
	end
end
