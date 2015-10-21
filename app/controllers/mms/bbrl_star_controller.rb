require 'mamashai_tools/taobao_util'
include MamashaiTools

class Mms::BbrlStarController < Mms::MmsBackEndController
	def index
		num = BbrlStar.first(:order=>"id desc").num
		@stars = BbrlStar.where(:num=>num)
	end

	def replace
		star = BbrlStar.find(params[:star_id])
		user = User.find_by_name(params[:name])
		if user
			star.user_id = user.id
			star.save
			Mms::Score.trigger_event(:xxb, "进入星星榜", 2, 1, {:user => user})
			render :text=>"替换成功"
		else
			render :text=>"找不到用户"
		end
	end
end
