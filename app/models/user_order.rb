class UserOrder < ActiveRecord::Base 
  belongs_to :user
  belongs_to :province
  belongs_to :city
  has_one :user_book
  
  validates_presence_of :user_id
  validates_presence_of :province_id,:message=>APP_CONFIG['error_user_province']
  validates_presence_of :city_id,:message=>APP_CONFIG['error_user_city']
  validates_presence_of :address,:message=>APP_CONFIG['error_user_address']
  validates_presence_of :post_code,:message=>APP_CONFIG['error_user_post_code']
  validates_presence_of :order_tp
  validates_presence_of :owner_name,:message=>APP_CONFIG['error_order_owner_name']
  validates_presence_of :owner_mobile,:message=>APP_CONFIG['error_order_owner_mobile']
  validates_presence_of :contact_name,:message=>APP_CONFIG['error_order_contact_name']
  validates_presence_of :contact_mobile,:message=>APP_CONFIG['error_order_contact_mobile']
  validates_presence_of :contact_email,:message=>APP_CONFIG['error_order_contact_email']
  validates_format_of :contact_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,:message=>APP_CONFIG['error_signup_email_wrong']
  
  
  def self.create_user_order(user,tp,params)
    user_order = UserOrder.new(:order_no=>Time.now.strftime("%Y%m%d%H%M%S")+MamashaiTools::TextUtil.rand_4_num_str,
         :user_id=>user.id,:money=>params[:money],:order_tp=>tp,
         :owner_name=>user.name,:owner_mobile=>user.mobile,:province_id=>user.province_id,:city_id=>user.city_id,
         :contact_name=>user.name,:contact_mobile=>user.mobile,:contact_email=>user.email)
    user_order.save_without_validation
    user_order
  end
  
end
