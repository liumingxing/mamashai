class Zhanting < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  def self.json_attrs
    [:id, :age_id, :gandong_count, :post_count, :created_at]
  end
  
  def as_json(options = {})
    options[:only] ||= Zhanting.json_attrs
    #options[:include] = [:tao_topic]
    options[:include] ||= {:user=>{:only=>User.json_attrs, :methods=>User.json_methods, :include=>{:user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}}}
    super options
  end
end
