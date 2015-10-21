#require 'rmmseg'
#include RMMSeg

class TaoProduct < ActiveRecord::Base
	belongs_to :category, :class_name=>"TaoProduct"
	has_many :comments, :class_name=>"TaoComment", :foreign_key=>"product_id", :order=>"created_at desc"
	before_create :make_rmmseg
	named_scope :normal, :conditions=>["tao_products.cancel = 0"]

	has_and_belongs_to_many :tao_ages

	def make_rmmseg
	    self.name_ = RMMSeg::segment(self.name).join(' ')
	end

	def posts
		return []
		#Post.find(:all, :conditions=>"`from`='taotaole' and from_id = #{self.id}", :order=>"id desc")
	end

	def logo200
		self.pic_url + "_200x200.jpg"
	end

	def logo400
		self.pic_url + "_400x400.jpg"
	end

	def logo
		self.pic_url
	end
		
	def self.json_attrs
	    %w{id name iid o_price price url_mobile short_url}
	end

	def self.json_methods
	    %w(logo200 logo400 logo posts)
	end

	def as_json(options = {})
	    options[:only] = (options[:only] || []) + TaoProduct.json_attrs
	    options[:methods] = (options[:methods] || []) + TaoProduct.json_methods
	    super options
	end
end
