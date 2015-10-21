class TaobaoComment < ActiveRecord::Base
  belongs_to :product, :class_name=>"TaobaoProduct", :foreign_key=>"product_id"
  belongs_to :user
  
  after_create :make_score
  
  def user
    if self.user_logo
      return nil
    else
      User.find(:first, :conditions=>"id = #{self.user_id}")
    end
  end
  
  def make_score
    woyongguo = Woyongguo.find(:first, :order=>"id desc")
    ids = woyongguo.products.collect{|m| m.taobao_product_id }
    ids << -1
    
    if ids.include?(self.product_id) && TaobaoComment.count(:conditions=>"user_id = #{self.user_id} and product_id in (#{ids.join(',')})") <= 2
      Mms::Score.trigger_event(:tao_comments, "参与我用过活动", 1, 1, {:user => self.user})
    end
  end
end
