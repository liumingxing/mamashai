class Api::MbookController < Api::ApplicationController
  before_filter :authenticate!, :except=>[:list, :album_list, :album_list2, :album_templates, :album_template, :album_book, :check_discount_code]
    
	#获取mbook列表
	def list
	  conditions = ["1=1"]
	  conditions << params[:cond] if params[:cond]
	  if params[:id]
	    conditions << "user_id = #{params[:id]}"
	  end
	  books = Mbook.find(:all, :conditions=>conditions.join(' and '), :order=>"id desc", :limit=>16)
	  render :json=>books
	end
	
	#上传一本mbook
	def upload
	  book = Mbook.new
	  if params[:id]
	    book = Mbook.find_by_id(params[:id])
	  else
	  	book.user_id = @user.id
	  end
	  book.name = params[:name]
	  book.json = params[:json]
	  book.logo = params[:logo] if params[:logo]
	  book.save
	  render :json=>book
	end
	
	#上传一页中的一张图片
	def upload_page
	  page = MbookPage.new 
	  page.logo = params[:logo]
	  page.user_id = @user.id
	  page.save
	  render :json=>page
	end
	
	#删除一本书
	def delete
	  book = Mbook.find_by_id(params[:id])
	  if !book
	    render :text=>"not found"
	  else  
	    if book.user_id == @user.id
	      book.destroy
	      render :text=>"ok"
	    else
	      render :text=>"error"
	    end
	  end
	end

################################################################################
	#获取照片书模板列表
	def album_templates
		album_templates = AlbumTemplate.find(:all, :order=>"position", :conditions=>"hide = 0")
		render :json=>album_templates
	end

	#获得一本书
	def album_book
		book = AlbumBook.find(params[:id])
		#book.view_count += 1
		#book.save
		AlbumBook.update_all "view_count = view_count + 1", "id = #{params[:id]}"
		render :text=>book.to_json(:only=>AlbumBook.full_json_attrs)
	end

	#获取照片书列表，带content内容，结果长度较大，终端解析时间较长
	def album_list
	  conditions = ["1=1"]
	  conditions << "recommand = 1" if !params[:all]
	  conditions << params[:cond] if params[:cond]
	  params[:per_page] ||= 10
	  if params[:id]
	    conditions << "user_id = #{params[:id]}"
	  end
	  if params[:template_id]
	  	conditions << "template_id = #{params[:template_id]}"
	  end
	  books = AlbumBook.not_hide.paginate :page=>params[:page], :per_page=>params[:per_page], :conditions=>conditions.join(' and '), :order=>"id desc", :total_entries=>1000
	  render :text=>books.to_json(:only=>AlbumBook.full_json_attrs)
	end

	#获取照片书列表，不带content内容，结果长度较小，终端解析时间短
	def album_list2
	  conditions = ["1=1"]
	  conditions << "recommand = 1" if !params[:all]
	  conditions << params[:cond] if params[:cond]
	  params[:per_page] ||= 10
	  if params[:id]
	    conditions << "user_id = #{params[:id]}"
	  end
	  if params[:template_id]
	  	conditions << "template_id = #{params[:template_id]}"
	  end
	  books = AlbumBook.not_hide.paginate :select=>"id, user_id, name, logo, logo1, template_id, created_at, updated_at, like_count, comment_count, kid_id, recommand", :page=>params[:page], :per_page=>params[:per_page], :conditions=>conditions.join(' and '), :order=>"id desc", :total_entries=>1000
	  render :json=>books
	end

	def album_upload
	  book = AlbumBook.new
	  if params[:id]
	    book = AlbumBook.find_by_id(params[:id])
	    if !book
		  book = AlbumBook.new 
		  book.user_id = @user.id
		end
	  else
	  	book.user_id = @user.id
	  end
	  book.name = params[:name]
	  book.kid_id = params[:kid_id]
	  book.json_bak = book.content
	  book.content = params[:json]
	  book.logo = params[:logo] if params[:logo]
	  book.template_id = params[:template_id]
	  book.save
	  book.make_mv
	  render :text=>book.to_json(:only=>AlbumBook.full_json_attrs)
	end

	def album_upload_page
	  page = AlbumPage.new 
	  page.logo = params[:logo]
	  page.user_id = @user.id
	  page.save
	  render :json=>page
	end

	#删除一本书
	def album_delete
	  book = AlbumBook.find_by_id(params[:id])
	  if !book
	    render :text=>"not found"
	  else  
	    if book.user_id == @user.id
	      book.destroy
	      render :text=>"ok"
	    else
	      render :text=>"error"
	    end
	  end
	end

	def album_template
	    pages = AlbumTemplatePage.find(:all, :conditions=>"album_template_id=#{params[:id]} and status='run'", :order=>"position")
	    render :json=>pages
	end

	#检查优惠码
	def check_discount_code
		code = AlbumDiscountCode.find_by_code(params[:code])
		if code
			if code.order_id
				order = AlbumOrder.find_by_id(code.order_id)
				if order.status != "未付款"
					render :text=>"used"
				else
					render :text=>code.amount
				end	
			else
				render :text=>code.amount
			end
		else
			render :text=>"no"
		end 
	end	

	#提交一个订单
	def make_order
		order = AlbumOrder.new()
		order.user_id = @user.id
		order.book_id = params[:book_id]
		order.address = params[:address]
		order.telephone = params[:mobile]
		order.linkname = params[:name]
		order.postcode = params[:code]
		order.price = params[:price]
		order.book_count = params[:count] if params[:count]
		order.status = "未付款"
		order.save

		if params[:discount_code] && params[:discount_code].to_s.size > 0
			code = AlbumDiscountCode.find_by_code(params[:discount_code])
			if code
				code.order_id = order.id
				code.save
			end
		end

		render :json=>order
	end

	#我的订单
	def album_my_order
		orders = AlbumOrder.find_by_sql("select album_orders.* from album_orders, album_books
where album_orders.book_id = album_books.id and album_orders.user_id = #{@user.id}")
		#orders = AlbumOrder.find(:all, :conditions=>"user_id = #{@user.id}", :order=>"id desc")
		render :json=>orders
	end

	#自动提示的书
	def auto_books
		result = []

		kid_id = params[:kid_id]
		kid = UserKid.find_by_id(kid_id)

		#to do : 判断孩子与用户是否是从属关系

		if !kid
			render :json=>result and return;
		end
		
		birthday = kid.birthday
		#孕期时光， 孕0到40周
		result << {:name => "孕期时光", 
						:template_id=>1,
						:template_json => AlbumTemplatePage.find(:all, :conditions=>"album_template_id=1 and status='run'", :order=>"position"),
						:from => birthday.ago(40.weeks).to_s(:db),
						:to => birthday.since(1.days).to_s(:db),
						:logo => AlbumTemplate.find(1).logo.url,
						:logo_thumb300 => AlbumTemplate.find(1).logo.thumb300.url
				}

		
		#出生到满月
		if Date.today - kid.birthday > 30 
			result << {:name => "#{kid.name}满月", 
						:template_id=>3,
						:template_json => AlbumTemplatePage.find(:all, :conditions=>"album_template_id=3 and status='run'", :order=>"position"),
						:from => birthday.to_s(:db),
						:to => birthday.since(1.months).since(1.days).to_s(:db),
						:logo => AlbumTemplate.find(3).logo.url,
						:logo_thumb300 => AlbumTemplate.find(3).logo.thumb300.url
					}
		end	

		#百天
		if Date.today - kid.birthday > 100 
			result << {:name => "#{kid.name}百天", 
						:template_id=>4,
						:template_json => AlbumTemplatePage.find(:all, :conditions=>"album_template_id=4 and status='run'", :order=>"position"),
						:from => birthday.since(1.months).to_s(:db),
						:to => birthday.since(101.days).to_s(:db),
						:logo => AlbumTemplate.find(4).logo.url,
						:logo_thumb300 => AlbumTemplate.find(4).logo.thumb300.url
					}
		end		

		#半岁
		if Date.today - kid.birthday > 180 
			result << {:name => "#{kid.name}半岁", 
						:template_id=>6,
						:template_json => AlbumTemplatePage.find(:all, :conditions=>"album_template_id=6 and status='run'", :order=>"position"),
						:from => birthday.since(100.days).to_s(:db),
						:to => birthday.since(182.days).to_s(:db),
						:logo => AlbumTemplate.find(6).logo.url,
						:logo_thumb300 => AlbumTemplate.find(6).logo.thumb300.url
					}
		end		

		#0到1岁好时光
		if Date.today - kid.birthday > 180 
			result << {:name => "0到1岁好时光", 
						:template_id=>5,
						:template_json => AlbumTemplatePage.find(:all, :conditions=>"album_template_id=5 and status='run'", :order=>"position"),
						:from => birthday.to_s(:db),
						:to => birthday.since(1.years).to_s(:db),
						:logo => AlbumTemplate.find(5).logo.url,
						:logo_thumb300 => AlbumTemplate.find(5).logo.thumb300.url
					}
		end	

		1.upto(5) do |i|
			#1岁生日
			if Date.today - kid.birthday > 365*i
				result << {:name => "#{i}岁好时光", 
							:template_id=>5,
							:template_json => AlbumTemplatePage.find(:all, :conditions=>"album_template_id=5 and status='run'", :order=>"position"),
							:from => birthday.since(i.years).to_s(:db),
							:to => birthday.since((i+1).years).to_s(:db),
							:logo => AlbumTemplate.find(5).logo.url,
							:logo_thumb300 => AlbumTemplate.find(5).logo.thumb300.url
						}
			end

		end

		6.upto(8) do |i|
			#1岁生日
			posts = Post.find(:all, :limit=>1, :conditions=>["created_at >= ? and created_at < ? and user_id = ?", birthday.since(i.years).to_s(:db), birthday.since((i+1).years).to_s(:db), kid.user_id])
			if posts.size > 0
				result << {:name => "#{i}岁好时光", 
							:template_id=>5,
							:template_json => AlbumTemplatePage.find(:all, :conditions=>"album_template_id=5 and status='run'", :order=>"position"),
							:from => birthday.since(i.years).to_s(:db),
							:to => birthday.since((i+1).years).to_s(:db),
							:logo => AlbumTemplate.find(5).logo.url,
							:logo_thumb300 => AlbumTemplate.find(5).logo.thumb300.url
						}
			end

		end
		
		render :text=>result.reverse.to_json
	end

	#改名字
	def album_change_name
		book = AlbumBook.find_by_id(params[:id])
		if book.user_id == @user.id
			book.name = params[:name]
			book.save
			render :text=>"success" and return
		end
		render :text=>"error"
	end

	#隐藏一本照片书
	def hide_book
		book = AlbumBook.find_by_id(params[:id])
		if book && book.user_id == @user.id
			book.is_hide = true
			book.save
			render :text=>"success" and return
		end
		render :text=>"error"
	end
end
