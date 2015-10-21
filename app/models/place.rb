class Place < ActiveRecord::Base
  # attr_accessible :title, :body
  before_create :parse_json

  def parse_json
  	poi = ActiveSupport::JSON.decode(self.json)
  	self.business_id= poi["business_id"]
  	self.latitude 	= poi["latitude"]
  	self.longitude 	= poi["longitude"]
  	self.name		= poi["name"]
  	self.branch_name= poi["branch_name"]
  	self.logo 		= poi["s_photo_url"]
  	self.logo_large = poi["photo_url"]
  	self.city 		= poi["city"]
  	self.address	= poi["address"]
  	self.price 		= poi["avg_price"]
  	self.avg_rating	= poi["avg_rating"]
  	self.rating_s_img_url = poi["rating_s_img_url"]
    self.url        = poi["business_url"]
  end

  def self.json_attrs
    %w(id business_id name branch_name logo logo_large city address price latitude longitude avg_rating rating_s_img_url url json)
  end

  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址30x30
  #
  def self.json_methods
    %w{}
  end
  
  def as_json(options = {})
    options[:only] ||= Place.json_attrs
    options[:methods] ||= Place.json_methods
    super options
  end
end
