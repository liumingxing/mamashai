class BafuFormController < ApplicationController
	layout false
	
	def index
		@articles = Article.find(:all, :conditions=>"article_category_id = 47", :order=>"id desc", :limit=>100)
	end
	
	def new
		@form = BafuForm.new	
	end
	
	def create
		@form = BafuForm.new(params[:form])
		@form.save
		
		redirect_to :action=>"index", :alert=>true
		
		Mailer.deliver_email(Mailer.send_bafu_email(@form))
	end
	
	def article
		article = Article.find(params[:id])
		render :text => article.article_content.content
	end
end
