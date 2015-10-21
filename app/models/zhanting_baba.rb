class ZhantingBaba < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :post
  belongs_to :user

  def self.json_attrs
    [:id, :user_id, :post_id, :desc, :light_count, :dark_count, :created_at]
  end
  
  def as_json(options = {})
    options[:only] ||= ZhantingBaba.json_attrs
    options[:include] ||= {:user=>{:only=>User.json_attrs, :methods=>User.json_methods}, :post=>{:only=>Post.json_attrs, :methods=>Post.json_methods}}
    super options
  end
end
