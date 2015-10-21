class ABaokuan < ActiveRecord::Base
  # attr_accessible :title, :body

  validates_presence_of :a_product_id, :message=>"选择商品"
  belongs_to :product, :class_name=>"AProduct", :foreign_key=>"a_product_id"

  def is_current
    self.begin_at < Time.new && self.stop_at > Time.new
  end

  #抢光了
  def no_remain
    AOrderDetail.sum(:count, :conditions=>"a_product_id = #{self.a_product_id} and a_orders.status = '待发货'", :joins=>"left join a_orders on a_orders.id = a_order_details.a_order_id") >= self.count
  end

  def self.json_attrs
    %w(id product_id price begin_at stop_at)
  end

  def as_json(options = {})
    options[:only] ||= ABaokuan.json_attrs
    options[:methods] = %w(is_current no_remain)
    options[:include] = {:product=>{:only=>AProduct.json_attrs, :methods=>AProduct.json_methods}}
    super options
  end
end
