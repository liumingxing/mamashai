class DdhOrder < ActiveRecord::Base
  before_create :make_status

  belongs_to :ddh
  belongs_to :user

  after_create :send_aps1
  after_update :send_aps2

  def make_status
    if self.ddh.score<=5
      self.status = '等待审核'
    else
      self.status = '等待发货'
    end
  end

  def send_aps1
    if self.ddh.score<=5
      MamashaiTools::ToolUtil.push_aps(self.user_id, "我们收到了您的'#{ddh.title}'试用申请，请等待商家审核。", {"t"=>"score"})
    else
      MamashaiTools::ToolUtil.push_aps(self.user_id, "您刚刚提交了一个兑换'#{ddh.title}'的订单", {"t"=>"score"})
    end
  end

  def send_aps2
  	if self.ddh.score<=5
      MamashaiTools::ToolUtil.push_aps(self.user_id, "您的'#{ddh.title}'试用申请，订单状态更新为：#{self.status}。", {"t"=>"score"})
    else
      if self.sent_at
       MamashaiTools::ToolUtil.push_aps(self.user_id, "您的豆豆换订单（#{ddh.title}）#{self.status}，时间是: #{self.updated_at.to_date.to_s}", {"t"=>"score"})
      end
    end
  end

  def has_made_report
    return true if Post.find(:first, :conditions=>"user_id = #{self.user_id} and `from`='ddh_report' and from_id = #{self.ddh_id}")
    
    return false
  end

  def self.json_attrs
    [:id, :ddh_id, :user_id, :name, :mobile, :address, :code, :remark, :sent_at, :created_at, :sent_at, :status, :kd_sn]
  end
  
  def self.json_methods
    [:has_made_report]
  end

  def as_json(options = {})
    options[:only] ||= DdhOrder.json_attrs
    options[:methods] ||= DdhOrder.json_methods
    super options
  end

end
