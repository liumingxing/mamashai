class CommentAtRemind < ActiveRecord::Base
	#attr_accessible :author

	belongs_to :comment
	#belongs_to :author, :class_name=>"User", :foreign_key=>"author_id"
	belongs_to :clap, :foreign_key=>"comment_id"
	belongs_to :post, :foreign_key=>"comment_id"
	belongs_to :gift_get, :foreign_key=>"comment_id"

	before_create :get_author_id

	def author
		@author = User.find(self.author_id)
	end
	
	def get_author_id
		if self.tp == 'comment' && self.comment
			self.author_id = self.comment.user_id  
		elsif self.tp == 'clap' && self.clap
			self.author_id = self.clap.user_id
		elsif self.tp == 'post' && self.post
			self.author_id = self.post.user_id 
		end

		return false if self.author_id == self.user_id
	end

	def clap_post
		if self.clap.tp == 'post'
			Post.find(self.clap.tp_id)
		elsif self.clap.tp == 'album'
			Post.first(:conditions=>"`from`='album_book' and from_id = #{self.clap.tp_id}")
		end
	end

	def self.json_attrs
	    [:id, :created_at, :tp]
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
	    options[:include] = {:author=>{:only=>User.json_attrs, :methods=>User.json_methods}}
	    
	    if self.tp == 'comment'		#评论
	    	options[:include][:comment] = {:only=>Comment.json_attrs, :include=>{:post=>{:only=>Post.json_attrs + [:user_id], :methods=>[:logo_url, :logo_url_thumb120, :logo_url_thumb400]}}}
	    elsif self.tp == 'post'		#转发
	    	options[:include][:post] = {:only=>Post.json_attrs, :include=>{:forward_post=>{:only=>Post.json_attrs, :methods=>Post.json_methods}}} 
	    elsif self.tp == "gift"
	    	options[:include][:gift_get] = {:only=>GiftGet.json_attrs, :methods=>GiftGet.json_methods, :include=>{:gift=>{:only=>Gift.json_attrs, :methods=>Gift.json_methods}}}
	    elsif self.tp == "clap"
	    	options[:include][:clap_post] = {:only=>Post.json_attrs, :methods=>[:logo_url, :logo_url_thumb120, :logo_url_thumb400]}
		end

	    super options
	  end
end
