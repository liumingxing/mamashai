class Qing2Controller < ApplicationController
	def index
		render :action=>"tips"
	end

	def tips
	end

	def yun
		params[:id] ||= 1
		params[:id] = 1 if params[:id].to_i > 40 || params[:id].to_i < 1
		@week = CalEnd::Weeks.find(params[:id])
	end

	def yu0
		params[:id] ||= 1
		params[:id] = 1 if params[:id].to_i > 12 || params[:id].to_i < 1
		@week = CalEnd::Fayu.find_by_month(params[:id])
	end

	def yu1
		params[:id] ||= 12
		params[:id] = 12 if params[:id].to_i > 36 || params[:id].to_i < 12
		@week = CalEnd::Fayu.find_by_month(params[:id])
	end

	def yu3
		params[:id] ||= 1
		params[:id] = 1 if params[:id].to_i > 12 || params[:id].to_i < 1
		@week = CalEnd::Chengzhang.find_by_month(params[:id])
	end

	def posts
		params[:page] ||= 1
		@posts = Post.not_private.not_hide.paginate(:page=>params[:page], :per_page=>20, :total_entries=>1000, :order=>"id desc")
	end

	def articles
		params[:page] ||= 1
		@articles = Article.publish.paginate(:page=>params[:page], :per_page=>10, :order=>"id desc")
	end

	def article
		@article = Article.find(params[:id])
	end

	def push_aps
		MamashaiTools::ToolUtil.push_aps(270, params[:text])
		#MamashaiTools::ToolUtil.push_aps(1433213, params[:text])
		#MamashaiTools::ToolUtil.push_aps(1433327, params[:text])
		render :text=>"ok"
	end
end
