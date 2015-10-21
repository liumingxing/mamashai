class AlbumOrder < ActiveRecord::Base
	after_create :make_status
  has_one :album_discount_code, :foreign_key=>"order_id"
  belongs_to :book, :class_name=>"AlbumBook";
  belongs_to :user

  after_create :send_aps1
  after_update :send_aps2

  def send_aps1
    MamashaiTools::ToolUtil.push_aps(self.user_id, "您刚刚提交了一个照片书订单，订单号为#{self.id}")
  end

  def send_aps2
    MamashaiTools::ToolUtil.push_aps(self.user_id, "您的照片书订单（#{self.id}），状态为: #{self.status}")
  end

	def make_status
		if self.status == "未付款" && self.price <= 0
			self.status = "已支付"
		end
	end

  def self.json_attrs
    [:id, :book_id, :user_id, :book_count, :status, :address, :telephone, :linkman, :postcode, :price, :created_at, :updated_at]
  end

  def self.json_methods
    %w{book_logo book_logo_thumb300 book_logo_thumb500 discount_code discount_amount}
  end

  def discount_code
    if self.album_discount_code
      self.album_discount_code.code
    else
      nil
    end
  end

  def discount_amount
    if self.album_discount_code
      self.album_discount_code.amount
    else
      nil
    end
  end

  def book_logo
    self.book.logo1.try(:url)
  end

  def book_logo_thumb300
    self.book.logo1_thumb300.try(:url)
  end

  def book_logo_thumb500
    self.book.logo1_thumb500.try(:url)
  end
  
  def as_json(options = {})
    options[:only] ||= AlbumOrder.json_attrs
    options[:methods] ||= AlbumOrder.json_methods
    super options
  end
end
