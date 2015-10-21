class Mms::AorderController < Mms::MmsBackEndController
	def list
		conditions=["1=1"]
		conditions << "status='#{params[:status]}'" if params[:status]
		conditions << "user_id=#{params[:user_id]}" if params[:user_id]
		@orders = AOrder.paginate(:page=>params[:page], :per_page=>20, :conditions=>conditions.join(" and "), :order=>"pay_at desc, id desc")
	end

	def payments 
		@payments = APayment.all(:order=>"id desc")
	end

	def fahuo
		order = AOrder.find(params[:id])
		order.sn = params[:sn]
		order.status = "已发货"
		MamashaiTools::ToolUtil.push_aps(order.user_id, "亲，您有一个订单已发货！")
		order.save
		flash[:notice] = "发货成功"
		redirect_to :action=>"list", :page=>params[:page]
	end

	def download
		order = AOrder.find(params[:id])
		if params[:t] == "1"
			send_file order.id_logo1.path, :filename=>"#{order.id_code}-1.jpeg"
		elsif params[:t] == "2"
			send_file order.id_logo2.path, :filename=>"#{order.id_code}-2.jpeg"
		end
	end

	def buy_list
		@orders = AOrder.paginate :page=>params[:page], :per_page=>10, :order=>"id desc", :conditions=>"status <> '待付款'"
	end

	def save_buy_info
		@detail = AOrderDetail.find_by_id(params[:id])
		@detail.update_attributes(params[:detail])
		@detail.save
		flash[:notice] = '设置信息成功'
		redirect_to :action=>"buy_list", :page=>params[:page]
	end

	def buy
		#date = params[:date]||Time.new.ago(24.hours).to_date
		conditions = ["1=1"]
		@date = Time.new.to_date
		if params[:naifen] == "2"
			conditions << "a_products.category_id <> 1"
		else
			conditions << "a_products.category_id = 1"
		end
		if params[:date]
			month = params["date"]["month"]
			month = "0" + month if month.to_i < 10
			@date = Date.parse("#{params['date']['year']}-#{month}-#{params['date']['day']}")
		end
		conditions << "date='#{@date.to_s}'"
		@reports = AReport.all(:joins=>"left join a_products on a_products.id = a_reports.a_product_id", :conditions=>conditions.join(" and "))
	end

	def set_buy_price
		if params[:report_price]
			params[:report_price].each{|key, value|
				report = AReport.find(key)
				report.price_market_aus = value
				report.save
			}
		end
		flash[:notice] = "设置价格成功"
		redirect_to :action=>"buy"
	end
end
