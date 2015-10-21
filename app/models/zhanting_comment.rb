class ZhantingComment < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :user
  belongs_to :author, :class_name=>"User"

  def self.json_attrs
    [:id, :user_id, :author_id, :content, :created_at]
  end
  
  def as_json(options = {})
    options[:only] ||= ZhantingComment.json_attrs
    #options[:include] = [:tao_topic]
    options[:include] ||= {:user=>{:only=>User.json_attrs, :methods=>User.json_methods, :include=>{:user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}}}
    super options
  end
end
