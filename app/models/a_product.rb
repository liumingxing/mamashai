class AProduct < ActiveRecord::Base
  # attr_accessible :title, :body
  upload_column :logo ,:process => '800x800', :versions => {:thumb100 => "100x100", :thumb200 => "276x276", :thumb400 => "400x400", :thumb600 => "600x600"}

  has_many :logos, :class_name=>"ALogo", :foreign_key=>"aproduct_id"
  has_and_belongs_to_many :articles

  after_create :upload_to_aliyun
  def upload_to_aliyun
    return if !self.logo
    return if !File.exist?(self.logo.path)
    
    begin                     
      $connection.put("upload/aproduct/#{self.id}/logo/#{self.logo.filename}", File.open(self.logo.path), {:content_type => self.logo.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/aproduct/#{self.id}/logo/#{self.logo.thumb100.filename}", File.open(self.logo.thumb100.path), {:content_type => self.logo.thumb100.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/aproduct/#{self.id}/logo/#{self.logo.thumb200.filename}", File.open(self.logo.thumb200.path), {:content_type => self.logo.thumb200.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/aproduct/#{self.id}/logo/#{self.logo.thumb400.filename}", File.open(self.logo.thumb400.path), {:content_type => self.logo.thumb400.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/aproduct/#{self.id}/logo/#{self.logo.thumb600.filename}", File.open(self.logo.thumb600.path), {:content_type => self.logo.thumb600.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
    rescue
    end
  end

  def self.json_attrs
    %w(id category_id code name price o_price score_rate weight age fee from packet bzq model kd brand sell_total sell_month sell_week created_at)
  end

  def price
    baokuan = ABaokuan.find_by_a_product_id(self.id, :conditions=>"begin_at < '#{Time.new.to_s(:db)}' and stop_at > '#{Time.new.to_s(:db)}'", :order=>"id desc")
    if baokuan && Time.new > baokuan.begin_at && Time.new < baokuan.stop_at && !baokuan.no_remain
      baokuan.price
    else
      self['price'].to_f
    end
  end

  def logo_url
    self.logo.try(:url)
  end
  
  def logo_thumb200
    self.logo ? self.logo.thumb200.url : nil
  end

  def logo_thumb400
    self.logo ? self.logo.thumb400.url : nil
  end

  def logo_thumb600
    self.logo ? self.logo.thumb600.url : nil
  end

  def is_baokuan
    baokuan = ABaokuan.find_by_a_product_id(self.id)
    baokuan && baokuan.begin_at < Time.new && baokuan.stop_at > Time.new && AOrderDetail.sum(:count, :conditions=>"a_product_id = #{self.id} and a_orders.status = '待发货'", :joins=>"left join a_orders on a_orders.id = a_order_details.a_order_id") < baokuan.count
    
#    Rails.cache.fetch("is_baokuan_#{self.id}", :expires_in=>10.minutes){
#      baokuan = ABaokuan.find_by_a_product_id(self.id)
#      baokuan && baokuan.begin_at < Time.new && baokuan.stop_at > Time.new
#    }
  end
  
  def self.json_methods
    %w{logo_url logo_thumb200 logo_thumb400 logo_thumb600 is_baokuan}
  end

  def as_json(options = {})
    options[:only] = options[:only] ? AProduct.json_attrs + options[:only] : AProduct.json_attrs
    options[:methods] = options[:methods] ? AProduct.json_methods + options[:methods] : AProduct.json_methods
    options[:include] = {:articles=>{:only=>Article.json_attrs, :methods=>Article.json_methods}}
    super options
  end
end
