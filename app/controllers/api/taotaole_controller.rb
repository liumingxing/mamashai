require 'mamashai_tools/taobao_util'
require 'open-uri'
require 'uri'
include MamashaiTools

class Api::TaotaoleController < Api::ApplicationController
	#caches_page :baobao_categories, :yun_categories
	before_filter :authenticate!, :only=>%w(share_taobao_product)

	#查看购放心	
	def gou_fangxin
		user = User.find_by_email(URI.decode(params[:username])) if params[:username]
		cond = ["`from`='taotaole'"]
		cond << URI.decode(params[:cond]) if params[:cond]
		cond << URI.decode(params[:cond1]) if params[:cond1] 
		if params[:scope] == "sameage"
			cond << "age_id = #{user.age_id}" if user
		elsif params[:scope] == "follow"
			cond << "posts.user_id in (#{(user.follow_user_ids<<-1).join(',')})"
		elsif params[:scope] == "my"
			cond << "posts.user_id = #{user.id}"
		end

		if params[:tp]
			category = TaoCategory.find_by_code(params[:tp])
			if category 
				cond << "tao_products.category_id in (#{category.category_ids.join(',')})"
			end
		end

		posts = Post.not_hide.all(:limit=>params[:count]||15, :group=>"posts.from_id", :conditions=>cond.join(' and '), :order=>"posts.id desc", :joins=>"left join tao_products on tao_products.id = posts.from_id")
		render :json=>posts
	end

	#宝宝商品的类目
	def baobao_categories
		if params[:id] == '2'		#孕期
			categories = TaoCategory.find(:all, :conditions=>"parent_id = #{19} and hide = 0")
		else
			categories = TaoCategory.roots.delete_if{|r| 
				r.hide == 1 || r.id == 19 || (r.code=="-1" && !r.age.to_s.include?(params[:id].to_s)) || r.age_children.size == 0
			}
			for c in categories
				c.age_id = params[:id]
			end
		end
		
		if params[:c]			# 1:用品  2:扮靓  3:营养
			if params[:id].to_i == 2		#孕期
				h = {1 => [1313, 1315], 2 => [1311], 3 => [1317]}
				categories.delete_if{|r|
					!h[params[:c].to_i].include?(r.id)
				}
			else
				h = {1 => [15], 2 => [13], 3 => [11]}
				categories.delete_if{|r|
					!h[params[:c].to_i].include?(r.id)
				}
			end
		end

		render :json=>categories
	end

	#孕期商品类目
	def yun_categories
		root = TaoCategory.find(19)
		render :json=>root
	end

	#获得某个类目的商品 
	def products_of
		page = params[:page] || 1
		per_page = params[:per_page] || 27
		
		if params[:id] && params[:id] != "undefined"								#传入了类目
			category = TaoCategory.find_by_id(params[:id])
			if category
				if category.children.size > 0			#类目有子类目，乱序排列
					products = TaoProduct.normal.paginate(:page=>page, :per_page=>per_page, :conditions=>"category_id in (#{category.children.map{|m| m.id}.join(',')})", :order=>"position desc, iid desc")
				else									#类目无子类目
					products = TaoProduct.normal.paginate(:page=>page, :per_page=>per_page, :conditions=>"category_id = #{params[:id]}", :order=>"position desc, iid desc")
				end
			else
				render :json=>[] and return
			end
		else										#无类目
			products = TaoProduct.normal.paginate(:page=>page, :per_page=>per_page, :order=>"position desc, id desc")
		end
		render :json=>products
	end

	#获得某个月龄的商品
	def products_of_tao_age
		tao_age = TaoAge.find(params[:id])
		ids = (tao_age.tao_products.map{|c| c.id}<<-1).join(",")
		products = TaoProduct.normal.paginate(:page=>params[:page], :per_page=>params[:per_page]||27, :conditions=>"(o_price = price or o_price is null) and id in (#{ids})", :order=>"position desc, iid desc")
		render :json=>products
	end

	#获得妈妈晒的商品
	def products_of_mamashai
		products = TaoProduct.paginate :conditions=>"o_price > price and from_mamashai = 1", :page=>params[:page], :per_page=>params[:per_page]||27, :order=>"position desc, iid desc"

		#products = TaoProduct.paginate_by_sql("select tao_products.* from tao_recommands left join tao_products on tao_recommands.tao_product_id = tao_products.id where tao_products.id is not null order by tao_recommands.id desc ", {:page=>params[:page], :per_page=>params[:per_page]||27})
		#products = TaoProduct.normal.paginate(:page=>params[:page], :per_page=>params[:per_page]||27, :conditions=>"from_mamashai=1", :order=>"position desc, iid desc")
		render :json=>products
	end

	#热淘专题列表
	def hot_tao
		render :text=>"ok"
	end

	#根据传入的iid获得淘宝商品信息
	def taobao_product_info
		#access_params= {"fields"=>"num_iid,title,pic_url,price,promotion_price", "num_iid"=>params[:iid]}
	    
	    #json = MamashaiTools.taobao_call("taobao.item.get", access_params)
	    #logger.info(json)
	    #if json['item_get_response']['item']
	    #	json['item_get_response']['item']['pic_url'] += "_400x400.jpg"
	    #end
	    
	    json = MamashaiTools.taobao_call("taobao.tbk.items.detail.get", {"fields"=>"num_iid,title,pic_url,price,promotion_price", "num_iids"=>params[:iid]})
	    if json['tbk_items_detail_get_response']["total_results"] == 0
	    	render :json=>{"item_get_response"=>{"item"=>nil}}
	    else
	    	p_json = json["tbk_items_detail_get_response"]["tbk_items"]["tbk_item"][0]
	    	new_json = {"item_get_response"=>{"item"=>{"pic_url"=>p_json["pic_url"] + "_400x400.jpg", 
	    									  			"price"=>p_json["price"],
	    									  			"title"=>p_json["title"],
	    									  			"num_iid"=>p_json["num_iid"]
	    									   			}
	    									  }
	    				}
	    	render :json=>new_json				
	    end
	end

	#用户推荐淘宝商品
	def share_taobao_product
		json = MamashaiTools.taobao_call("taobao.tbk.items.detail.get", {"fields"=>"num_iid,title,pic_url,price,cid,detail_url,item_url", "num_iids"=>params[:iid]})
	    if json && json['tbk_items_detail_get_response'] && json['tbk_items_detail_get_response']['total_results'] == 1
	    		item = json['tbk_items_detail_get_response']['tbk_items']['tbk_item'][0]
	    		product = TaoProduct.find_by_iid(item["num_iid"])
	    		if !product
	    			product 		= TaoProduct.new 
		    		product.name 	= item["title"]
		    		product.pic_url = item["pic_url"]
		    		product.price 	= item["price"]
		    		product.iid 	= item["num_iid"]
		    		product.url 	= item["item_url"]
		    		product.url_mobile = item["item_url"]
		    		product.tao_topic_id = params[:topic_id]
		    		product.user_id = @user.id
		    		product.save

		    		begin
		    				token = Weibotoken.get('sina', 'babycalendar')
			    			user_weibo = UserWeibo.find(:first, :order=>"id desc")
			    			text = `curl 'https://api.weibo.com/2/short_url/shorten.json?url_long=#{URI.encode(product.url_mobile)}&source=#{token.token}&access_token=#{user_weibo.access_token}'`
			    			res_json = JSON.parse(text)
			    			if res_json['urls'] && res_json['urls'].size > 0
			    				product.short_url = res_json['urls'][0]["url_short"]
			    			end
			    	rescue => err
			    			logger.info(err)
			    	ensure
			    			product.save
			    	end
		    	end

	    		#发微博
		    	post = Post.new
		    	post.content = URI.decode(params[:text]) + " #{product.short_url}"
		    	post.user_id = @user.id
		    	post.from = 'taotaole'
		    	post.from_id = product.id

		    	file_name = "tmp/#{Time.new.to_i}#{rand(10000000)}.jpg"
		    	logger.info "wget -T 10 -q -T40 -O #{file_name} '#{product.pic_url + "_400x400.jpg"}'"
    			`wget -T 10 -q -T40 -O #{file_name} '#{product.pic_url + "_400x400.jpg"}'`
    			file = File.open(file_name)
		    	post.logo = file
		    	post.save
		    	file.close
	    else
	    	render :text=>"error"
	    end
		render :json=>params
	end

	#获得本站商品的详情
	def product_info
		product = TaoProduct.find_by_id(params[:id])
		render :json=>product
	end

	def tao_topic
		cond = ["status='online'"]
		cond << params[:cond] if params[:cond]
		topics = TaoTopic.find(:all, :conditions=>cond.join(' and '), :order=>"created_at desc, id desc")
		render :json=>topics
	end

	def tao_topic_product
		products = TaoProduct.normal.paginate(:page=>params[:page]||1, :per_page=>27, :conditions=>"cancel = 0 and tao_topic_id = #{params[:id]}", :order=>"created_at")
		render :json=>products
	end

	def yili_count
		YiliAdv.create(:ip=>request.env['REMOTE_ADDR'])
		render :text=>"ok"
	end

	def tao_youhui_categories
		render :json=>TaoYouhuiCategory.all(:order=>"id")
	end

	def tao_youhui_products
		cond = ["1=1"]
		cond << "youhui_code = #{params[:id]}" if params[:id]
		cond << "youhui_code = #{params[:code]}" if params[:code]
		cond << URI.decode(params[:cond]) if params[:cond]
		products = TaoYouhuiProduct.paginate :page=>params[:page]||1, :per_page=>20, :conditions=>cond.join(' and '), :order=>"iid", :group=>"iid"
		render :json=>products
	end

	def nick_of_taobao
		user = UserTaobao.find(:first, :conditions=>["user_id=?", params[:user_id]], :order=>"id desc")
		if user
			render :text=>user.taobao_nick
		else
			render :text=>""
		end
	end
end
