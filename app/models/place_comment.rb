class PlaceComment < ActiveRecord::Base
  belongs_to :user
  
  def place
  	Place.find_by_business_id(self.business_id)
  end
  # attr_accessible :title, :body
  def self.json_attrs
    %w(id user_id business_id rate qinzi sheshi shiyi qx content created_at)
  end

  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址30x30
  #
  def self.json_methods
    %w{}
  end

  
  def as_json(options = {})
    options[:only] ||= PlaceComment.json_attrs
    options[:methods] ||= PlaceComment.json_methods
    options[:include] ||= {:place=>{:only => Place.json_attrs, :methods=>Place.json_methods}, :user=>{:only=>User.json_attrs, :methods=>User.json_methods, :include=>{:user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}}}
    super options
  end
end
