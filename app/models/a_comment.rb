class AComment < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :logos, :class_name=>"ACommentLogo", :foreign_key=>"a_comment_id"
  belongs_to :user

  def self.json_attrs
    %w(id a_order_id a_order_detail_id a_product_id text star created_at)
  end

  def as_json(options = {})
    options[:only] = options[:only] ? AComment.json_attrs + options[:only] : AComment.json_attrs
    options[:include] = {:logos=>{:only=>ACommentLogo.json_attrs, :methods=>ACommentLogo.json_methods}, :user=>{:only=>User.json_attrs, :methods=>User.json_methods, :include=>{:user_kids=>{:only=>UserKid.json_attrs}}}}
    super options
  end
end
