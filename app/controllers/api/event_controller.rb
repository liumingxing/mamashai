class Api::EventController < Api::ApplicationController
	before_filter :authenticate!, :except=>[:time_album, :comments, :baba, :rand_pk, :investigate]

	#调查分享微信
	def share_diaocha_weixin
		if ScoreEvent.find(:first, :conditions=>"user_id = #{@user.id} and event = 'share_diaocha_2014'")
			render :text=>"repeat" and return;
		end

		code = CommandCode.new
		code.code = %Q!if ScoreEvent.find(:first, :conditions=>"user_id = #{@user.id} and event = 'share_diaocha_2014'") == nil
				Mms::Score.trigger_event(:share_diaocha_2014, '分享2014调查至朋友圈', 3, 1, {:user => User.find(#{@user.id})});
			end
		!
		code.after = Time.now.since(1.minutes)
		code.status = 'wait'
		code.save
		render :text=>"ok"
	end

	#请求一个红包
	def request_redpacket
		cs = params[:c].split(',')
	  	score = 0
	  	for c in cs
	  		score += c.to_i * 10
	  	end
	  	if score >= 300
	  		render :text=>"对不起，为让更多用户申领，目前只能申领最高20元的红包" and return
	  	end

	  	if @user.score < score
	  		render :text=>"对不起，你需要#{score}个晒豆，而您只有#{@user.score}晒豆" and return
	  	end

	  	if RedPacket.count(:conditions=>"user_id = #{@user.id} and status = '等待'") > 0
	  		render :text=>"对不起，你已经有在等待审核的请求了" and return
	  	end

	  	if RedPacket.count(:conditions=>"zhifubao = '#{params[:zhifubao]}' and created_at > '#{Time.new.ago(7.days).to_s(:db)}'") > 0
	  		render :text=>"对不起，您的支付宝已经提交过了。7天之内不能多次申领" and return
	  	end

	  	if RedPacket.count(:conditions=>"user_id = #{@user.id} and status = '成功' and created_at > '#{Time.new.ago(7.days).to_s(:db)}'") > 0
	  		render :text=>"对不起，7天之内不能多次申领" and return
	  	end

	  	if RedPacket.sum(:score, :conditions=>"updated_at > '#{Time.new.beginning_of_day.to_s(:db)}'") > 10000
	  		render :text=>"对不起，由于支付宝对红包发放有额度限制，今天红包发完了，记得明天早起再来哦！" and return
	  	end

	  	if RedPacket.sum(:score, :conditions=>"created_at > '#{Time.new.beginning_of_day.to_s(:db)}'") > 10000
	  		render :text=>"对不起，由于支付宝对红包发放有额度限制，今天红包发完了，记得明天早起再来哦！" and return
	  	end
	  	
		packet = RedPacket.new
		packet.user_id = @user.id
		packet.tp = params[:c]
		packet.zhifubao = params[:zhifubao]
		packet.save

		render :text=>"提交成功，请等待红包到账。"
	end

	#用户参与调研
	def investigate
		user = User.find_by_id(params[:user_id]) if params[:user_id]
		invest = Investigate.find_by_user_id(user.id) if user
		invest = Investigate.new if !invest
		invest.user_id = user.id if user
		invest.ip = request.ip
		invest.tp = 1
		1.upto(28) do |i|
			invest["s#{i}"] = params["s#{i}"]
		end
		invest.save

		if user
			if !ScoreEvent.find(:first, :conditions=>"user_id = #{user.id} and event = 'investigate'")
				Mms::Score.trigger_event(:investigate, '参与妈妈晒调研活动', 20, 1, {:user => user});
			end
		end

		render :text=>"提交成功，感谢您参与调研！"
	end

	def baoming
		if Zhanting.find_by_user_id(@user.id)
			render :text=>"对不起，您已经报过名了" 
			return
		end
		if @user.posts_count < 30
			render :text=>"对不起，您的记录数不足30"
			return
		end
		count = Post.count(:conditions=>["is_private=0 and is_hide = 0 and user_id = ?", @user.id])
		Zhanting.create(:user_id=>@user.id, :post_count=>count, :age_id=>@user.age_id)
		render :text=>"亲，恭喜您报名成功，您的时光轴已进入活动展厅"
	end

	def jietu
		z = ZhantingCapture.new
		z.user_id = @user.id
		z.logo = params[:logo]
		z.save
		render :text=>"上传截图成功"
	end

	def time_album
		@user = User.find_by_id(params[:user_id]) if params[:user_id]

		if params[:tp] == "new"
			render :json=>Zhanting.paginate(:page=>params[:page], :per_page=>10, :order=>"created_at desc")
		elsif params[:tp] == "order"
			render :json=>Zhanting.paginate(:page=>params[:page], :per_page=>10, :order=>"gandong_count desc")
		elsif params[:tp] == "sameage"
			render :json=>Zhanting.paginate(:page=>params[:page], :per_page=>10, :conditions=>["age_id = ?", @user.age_id])
		elsif params[:tp] == "follow"
			user = User.find(params[:user_id])
			render :json=>Zhanting.paginate(:page=>params[:page], :per_page=>10, :conditions=>"user_id in (#{user.follow_ids.join(",")})")
		elsif params[:tp] == "my"
			render :json=>Zhanting.all(:conditions=>["user_id = ?", @user.id])
		end
	end

	def make_comment
		if ZhantingComment.count(:conditions=>["user_id = ?", @user.id]) >= 30
			render :text=>"亲，最多只能提交感动30次！"
			return
		end

		if ZhantingComment.count(:conditions=>["user_id = ? and author_id = ?", @user.id, params[:author_id]]) > 0
			render :text=>"亲，对一个时光轴只能留下一次感动！"
			return
		end

		if @user.id == params[:author_id].to_i
			render :text=>"亲，不能给自己留下感动！"
			return
		end

		if ZhantingComment.find(:first, :conditions=>["author_id = ? and user_id = ?", params[:author_id], @user.id])
			render :text=>"亲，您已经提交过了！"
			return
		end
		
		comment = ZhantingComment.create(:author_id=>params[:author_id], :user_id=>@user.id, :content=>URI.decode(params[:content]))
		
		zhanting = Zhanting.find_by_user_id(params[:author_id])
		zhanting.gandong_count += 1
		zhanting.save
		
		render :text=>"ok"
	end

	def comments
		comments = ZhantingComment.all(:conditions=>["author_id = ?", params[:id]], :order=>"id desc")
		render :json=>comments
	end

	###########################爸爸在这儿###########################
	def upload_baba
		if ZhantingBaba.count(:conditions=>"user_id = #{@user.id} and huodong_id = #{params[:huodong_id]}") >1
			render :text=>"亲，请不要多次重复参与活动" and return
		end

		attr = {:post=>{:content=>URI::decode(params[:status]), :logo=>params[:pic], :from=>"huodong", :from_id=>params[:huodong_id]}}
		post = Post.create_post(attr,@user)
		render :text=>post.errors.map{|e| e.to_s}.join(",") and return if post.errors.present?
		
		baba = ZhantingBaba.create(:post_id=>post.id, :user_id=>@user.id, :age_id=>@user.age_id, :desc=>params[:status], :huodong_id=>params[:huodong_id])
		render :json=>post
	end

	def delete_baba
		baba = ZhantingBaba.find(params[:id])
		if baba.user_id == @user.id
			baba.destroy
		elsif @user.tp == 4
			baba.destroy
			Mms::Score.trigger_event(:delete_hll, '删除不合格活动照片', -15, 1, {:user => baba.user});
		end
		render :text=>"删除成功"
	end

	def rand_pk
		if ZhantingBaba.count(:conditions=>"huodong_id = #{params[:huodong_id]}") < 10
			render :json=>{:error=>"参赛数量还不足，无法PK"} and return;
		end

		if params[:user_id] && params[:user_id].to_s.size > 0
			flowers = ZhantingFlower.all(:conditions=>"user_id = #{params[:user_id]} and huodong_id = #{params[:huodong_id]}")
			ids = (flowers.map{|f| f.post_id}<<0).join(',')
			
			if rand(30) < 2
				babas = ZhantingBaba.all(:group=>"user_id", :conditions=>"created_at > '#{Time.new.ago(2.days).to_s(:db)}' and huodong_id=#{params[:huodong_id]} and post_id not in (#{ids})", :limit=>2, :order=>"rand()")
			elsif rand(30) < 15
				block_ids = Rails.cache.fetch("light_block_ids", :expires_in => 2.hours){ 
					block_ids = Blockname.all.collect{|b| b.user_id}
					block_ids += Blockpublic.all.collect{|b| b.user_id}
					block_ids += Blockstar.all.collect{|b| b.user_id}
					block_ids.uniq!
					block_ids
				}
				
				babas = ZhantingBaba.all(:group=>"user_id", :conditions=>"huodong_id=#{params[:huodong_id]} and post_id not in (#{ids}) and user_id not in (#{block_ids.join(',')})", :limit=>2, :order=>"rand()")
			else
				babas = ZhantingBaba.all(:group=>"user_id", :conditions=>"huodong_id=#{params[:huodong_id]} and post_id not in (#{ids})", :limit=>2, :order=>"rand()")
			end

			if babas.size < 2
				babas = ZhantingBaba.all(:group=>"user_id", :conditions=>"huodong_id=#{params[:huodong_id]} and post_id not in (#{ids})", :limit=>2, :order=>"rand()")
			end

			render :json=>{:error=>"参赛数量还不足，无法PK"} and return if babas.size < 2;
			render :json=>babas
		else
			babas = ZhantingBaba.all(:group=>"user_id", :conditions=>"huodong_id=#{params[:huodong_id]}", :limit=>2, :order=>"rand()")
			render :json=>babas
		end
		
	end

	#分享了微信朋友圈，该给豆了
	def share_weixin
		huodong = Pk.latest_end_time[params[:huodong_id].to_i]
		if Time.new.to_s(:db) > huodong.end_date.to_s(:db) #"2015-10-25 00:00:00"
			render :text=>"finished" and return
		end

		if ScoreEvent.find(:first, :conditions=>"user_id = #{@user.id} and event = 'join_pk_#{huodong.id}'")
			render :text=>"repeat" and return;
		end

		code = CommandCode.new
		code.code = %Q!if ScoreEvent.find(:first, :conditions=>"user_id = #{@user.id} and event = 'join_pk_#{huodong.id}'") == nil
				Mms::Score.trigger_event(:join_pk_#{huodong.id}, '参与#{huodong.title}活动', 15, 1, {:user => User.find(#{@user.id})});
			end
		!
		code.after = Time.now.since(10.minutes)
		code.status = 'wait'
		code.save
		render :text=>"ok"
	end

	def baba
		if params[:tp] == "new"
			posts = ZhantingBaba.paginate(:conditions=>"huodong_id=#{params[:huodong_id]}", :page=>params[:page], :per_page=>10, :order=>"id desc", :group=>"user_id")
		elsif params[:tp] == "order"
			posts = ZhantingBaba.paginate(:conditions=>"huodong_id=#{params[:huodong_id]}", :page=>params[:page], :per_page=>10, :order=>"light_count desc", :group=>"user_id")
		elsif params[:tp] == "sameage"
			authenticate!
			posts = ZhantingBaba.paginate(:page=>params[:page], :per_page=>10, :order=>"id desc", :conditions=>"age_id = #{@user.age_id} and huodong_id=#{params[:huodong_id]}", :group=>"user_id")
		elsif params[:tp] == "follow"
			authenticate!
			posts = ZhantingBaba.paginate(:page=>params[:page], :per_page=>10, :order=>"id desc", :conditions=>"user_id in (#{(@user.follow_ids << -1).join(',')}) and huodong_id=#{params[:huodong_id]}", :group=>"user_id")
		elsif params[:tp] == "my"
			authenticate!
			posts = ZhantingBaba.paginate(:page=>params[:page], :per_page=>10, :order=>"id desc", :conditions=>"user_id = #{@user.id} and huodong_id=#{params[:huodong_id]}")
		end
		render :json=>posts
	end

	def light
		huodong = Pk.latest_end_time[params[:huodong_id].to_i]
		if Time.new.to_s(:db) > huodong.end_date.to_s(:db)
			render :text=>"活动已结束" and return
		end

		baba = ZhantingBaba.find_by_id(params[:baba_id])
		
		flower = ZhantingFlower.find_by_post_id_and_user_id(baba.post_id, @user.id)

		if flower
			render :text=>"请不要重复亮灯" and return
		end
		
		ZhantingFlower.create(:post_id=>baba.post_id, :user_id=>@user.id, :tp=>params[:tp], :huodong_id=>baba.huodong_id)
		MamashaiTools::ToolUtil.push_aps(baba.user_id, "亲，#{@user.name}给您的#{huodong.title}照点了个亮灯！")
		baba.light_count = ZhantingFlower.count(:conditions=>"post_id=#{baba.post_id} and tp='light'")
		baba.save

		count = ZhantingFlower.count(:conditions=>"user_id = #{@user.id} and created_at > '#{Time.new.beginning_of_day}'");
		if count == 15 || count == 30 
			if ScoreEvent.count(:conditions=>"event='pk_light_#{huodong.id}' and user_id = #{@user.id} and created_day = '#{Time.new.to_date.to_s}'")<2
				Mms::Score.trigger_event("pk_light_#{huodong.id}".to_sym, "晒#{huodong.title}活动点灯15次", 1, 1, {:user => @user});
			end
		end

		render :text=>"成功亮灯"
	end


end