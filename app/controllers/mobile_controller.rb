class MobileController < ApplicationController

	def children_day
	end

	def post
		@post = Post.find_by_id(params[:id])
		@title = "分享一篇育儿记录"
		if @post && @post.from == 'album_book'
			redirect_to :action=>'album_book', :id=>@post.from_id 
			return
		end
		render :action=>"no_post" and return if !@post 
	end

	def article
		@article = Article.find_by_id(params[:id])
		@title = @article ? @article.title : "宝宝日历"
		render :action=>"no_article" and return if !@article 
	end

	def index
		render :action=>"bbrl", :layout=>false
	end

	def bbrl
		redirect_to :controller=>"bbrl", :action=>"mobile"
	end

	def album_book
		@book = AlbumBook.find_by_id(params[:id])
		@post = Post.find(:first, :conditions=>["`from`='album_book' and from_id = ?", @book.id])
		render :text=>"<h1>对不起，本书已不存在</h1>" and return if !@book
		render :text=>"<h1>对不起，本书图片还未上传</h1>" and return if !@book.logo1
		if !File.exists?(File.join(@book.logo1.dir, "..", "0.jpg"))
			@book.make_mv
		end

		@json = JSON.parse(@book.content)

		#if params[:density].to_i > 190 && params[:width].to_i <=320
		#	params[:scale] = 0.25
		#end
		
		render :layout=>false
	end
end
