class Favourite < ActiveRecord::Base
  belongs_to :post, :foreign_key=>"tp_id"
  belongs_to :article, :foreign_key=>"tp_id"
  belongs_to :user

  def self.json_attrs
	    [:id, :created_at, :tp]
  end

  def place
  	Place.find_by_business_id(self.tp_id)
  end

  # ==json_methods 输出方法
	  # * logo_url: 图片地址
	  # * logo_url_thumb99: 缩略图地址30x30
	  #
	  def self.json_methods
	   	[]
	  end
	  
	  def as_json(options = {})
	    options[:only] ||= CommentAtRemind.json_attrs
	    options[:methods] ||= CommentAtRemind.json_methods
	    options[:include] = {:user=>{:only=>User.json_attrs, :methods=>User.json_methods}}
	    
	    if self.tp == 'post'		#记录
	    	options[:methods] << "post"
	    	#options[:include][:post] = {:only=>Post.json_attrs, :include=>{:forward_post=>{:only=>Post.json_attrs, :methods=>Post.json_methods}}} 
	    elsif self.tp == 'article'		#宝典
	    	options[:methods] << "article"
	    	#options[:include][:comment] = {:only=>Comment.json_attrs, :include=>{:post=>{:only=>Post.json_attrs, :methods=>[:logo_url, :logo_url_thumb120, :logo_url_thumb400]}}}
	    	#options[:include][:article] = {:only=>Article.json_attrs, :methods=>Article.json_methods, :include=>{:article_content=>{:only=>[:content]}}}
	    	#article.to_json(:include=>{:article_content=>{:only=>[:content]}})	
	    elsif self.tp == "dianping"
	    	options[:methods] << "place"
	    end

	    super options
	  end
end
