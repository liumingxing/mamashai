class AOrderDetail < ActiveRecord::Base
  # attr_accessible :title, :body
  
  before_save :get_sum
  belongs_to :order, :class_name=>"AOrder", :foreign_key=>"a_order_id"
  belongs_to :product, :class_name=>"AProduct", :foreign_key=>"a_product_id"

  upload_column :product_logo ,:process => '800x800', :versions => {:thumb100 => "100x100", :thumb200 => "276x276", :thumb400 => "400x400", :thumb600 => "600x600"}
  upload_column :buy_logo1 ,:process => '800x800', :versions => {:thumb100 => "100x100", :thumb400 => "400x400"}
  upload_column :buy_logo2 ,:process => '800x800', :versions => {:thumb100 => "100x100",  :thumb400 => "400x400"}
  upload_column :kd_logo ,:process => '800x800', :versions => {:thumb100 => "100x100",  :thumb400 => "400x400"}

  before_save :check_valid
  before_save :get_product_info

  def check_valid
    if self.order.status == '待付款' && self.product.kd > self.count
      errors.add(:a_order_id, "亲，#{self.product.name}起购量至少#{self.product.kd}件哦!") 
      return false
    end
  end

  def get_product_info
    self.product_logo = File.open(self.product.logo.path)
    self.name = self.product.name
    self.english_name = self.product.english_name
  end

  after_create :upload_to_aliyun
  def upload_to_aliyun
    return if !self.product_logo
    #return if !File.exist?(self["product_logo"])
    return if !File.exist?(self.product_logo.path)
    
    begin                     
      $connection.put("upload/aorderdetail/#{self.id}/product_logo/#{self.product_logo.filename}", File.open(self.product_logo.path), {:content_type => self.product_logo.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/aorderdetail/#{self.id}/product_logo/#{self.product_logo.thumb100.filename}", File.open(self.product_logo.thumb100.path), {:content_type => self.product_logo.thumb100.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/aorderdetail/#{self.id}/product_logo/#{self.product_logo.thumb200.filename}", File.open(self.product_logo.thumb200.path), {:content_type => self.product_logo.thumb200.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/aorderdetail/#{self.id}/product_logo/#{self.product_logo.thumb400.filename}", File.open(self.product_logo.thumb400.path), {:content_type => self.product_logo.thumb400.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/aorderdetail/#{self.id}/product_logo/#{self.product_logo.thumb600.filename}", File.open(self.product_logo.thumb600.path), {:content_type => self.product_logo.thumb600.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
    rescue
    end
  end

  def logo
    self.product_logo ? self.product_logo.thumb200.url : nil
  end

  def logo_url
    self.product_logo.try(:url)
  end
  
  def logo_thumb200
    self.product_logo ? self.product_logo.thumb200.url : nil
  end

  def logo_thumb400
    self.product_logo ? self.product_logo.thumb400.url : nil
  end

  def logo_thumb600
    self.product_logo ? self.product_logo.thumb600.url : nil
  end

  def buy_logo1_url
    self.buy_logo1 ? self.buy_logo1.url : nil
  end

  def buy_logo2_url
    self.buy_logo2 ? self.buy_logo2.url : nil
  end

  def kd_logo_url
    self.kd_logo ? self.kd_logo.url : nil
  end

  def score_rate
    self.product.score_rate
  end

  def self.json_attrs
    %w(id name english_name a_product_id price o_price count sum created_at buy_date buy_price buy_channel buy_sn kd_at buy_remark)
  end

  def self.json_methods
    %w(logo logo_url logo_thumb200 logo_thumb400 logo_thumb600 score_rate buy_logo1_url buy_logo2_url kd_logo_url)
  end

  def as_json(options = {})
    options[:only] ||= AOrderDetail.json_attrs
    options[:methods] ||= AOrderDetail.json_methods
    super options
  end

  def get_sum
    self.sum = self.price * self.count
  end
end
