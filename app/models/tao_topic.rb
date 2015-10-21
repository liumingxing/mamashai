class TaoTopic < ActiveRecord::Base
	has_many :tao_products, :order=>"created_at"
	#upload_column :logo , :versions => {:thumb600 => "c600x200",:thumb700 => "c700x230"}
	upload_column :logo , :versions => {:thumb260 => "c260x290",:thumb50 => "c50x60"}

	validates_presence_of :logo, :message=>"必须上传一张图片"
	validates_presence_of :desc, :message=>"必须填写描述"

	def logo260
		self.logo.thumb260.url
	end
		
	def self.json_attrs
	    %w{id title desc created_at}
	end

	def self.json_methods
	    %w(logo260 product_counts tao_categories)
	end

	def tao_categories
		return [] if !self.tao_ids || self.tao_ids.size == 0
		TaoCategory.all(:conditions=>"id in (#{self.tao_ids})")
	end

	def product_counts
		TaoProduct.count(:conditions=>"tao_topic_id = #{self.id}")
	end

	def as_json(options = {})
	    options[:only] = (options[:only] || []) + TaoTopic.json_attrs
	    options[:methods] = (options[:methods] || []) + TaoTopic.json_methods
	    #options[:methods] << 'tao_categories' if self.tao_ids
	    super options
	end
end