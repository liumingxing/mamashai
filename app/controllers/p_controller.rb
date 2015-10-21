class PController < ApplicationController
	caches_page   :index
	caches_page   :comments

	def index
	end

	def hot
		@posts = Rails.cache.fetch("p_hotpost_#{params[:page]}", :expires_in=>10.minutes){
			Post.not_hide.not_visit.paginate :include=>%w(user post_logos),:page=>params[:page], :per_page=>40, :conditions=>"created_at >= '#{Time.new.ago(1.days).beginning_of_day.to_s(:db)}' and comments_count + claps_count + post_rates_count >= 20", :order=>"comments_count+claps_count+post_rates_count desc" 
		}
	end

	def gift
		@ddhs = Ddh.paginate :page=>params[:page], :per_page=>15, :order=>"status asc, id desc"
	end

	def show_gift
		@posts = Post.not_hide.not_private.paginate :per_page=>40, :page=>params[:page], :total_entries=>2000, :conditions=>"`from`='ddh_report'", :order=>"id desc"
	end

	def comments
		@comments = AppleGood.all(:order=>"occur")
	end

	def more
		render :text=>"hello"
	end
end
