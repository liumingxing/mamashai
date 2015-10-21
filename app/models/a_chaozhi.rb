class AChaozhi < ActiveRecord::Base
  # attr_accessible :title, :body
  validates_presence_of :a_product_id, :message=>"选择商品"
  belongs_to :product, :class_name=>"AProduct", :foreign_key=>"a_product_id"

  def is_current
    if self.begin_at < Time.new && self.stop_at > Time.new
      true
    else
      false
    end
  end

  def self.json_attrs
    %w(id product_id begin_at stop_at)
  end

  def as_json(options = {})
    options[:only] ||= AChaozhi.json_attrs
    options[:methods] = %w(is_current)
    options[:include] = {:product=>{:only=>AProduct.json_attrs, :methods=>AProduct.json_methods}}
    super options
  end
end
