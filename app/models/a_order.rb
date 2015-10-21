class AOrder < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :details, :class_name=>"AOrderDetail", :foreign_key=>"a_order_id"
  belongs_to :user
  belongs_to :address, :class_name=>"AAddress", :foreign_key=>"address_id"
  upload_column :id_logo1
  upload_column :id_logo2

  upload_column :buy_logo1, :versions => {:thumb100 => "100x100", :thumb400 => "400x400"}
  upload_column :buy_logo2, :versions => {:thumb100 => "100x100", :thumb400 => "400x400"}
  upload_column :kd_logo, :versions => {:thumb100 => "100x100", :thumb400 => "400x400"}


  before_create :make_receiver

  def make_receiver
    if self.address
      self.receiver = "#{self.address.receiver} #{self.address.mobile} #{self.address.city} #{self.address.address}"
      self.id_name = self.address.id_name
      self.id_code = self.address.id_code
      self.id_logo1 = self.address.id_logo1
      self.id_logo2 = self.address.id_logo2
    end
  end

  def self.json_attrs
    %w(id user_id price o_price score_amount vip_amount redpacket_amount redpacket_id payment paymethods status sn created_at)
  end

  def self.json_includes
    %w(address details)
  end
  
  def as_json(options = {})
    options[:only] ||= AOrder.json_attrs
    options[:include] = {:address=>{:only=>AAddress.json_attrs, :methods=>AAddress.json_methods}, :details=>{:only=>AOrderDetail.json_attrs, :methods=>AOrderDetail.json_methods}}
    super options
  end
end
