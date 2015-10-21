class PostLogo < ActiveRecord::Base
  after_create :upload_to_aliyun

  # attr_accessible :title, :body
  upload_column :logo,:process => '800x4000', :versions => {:thumb200 => "c200x200", :thumb400 => "1000x600"}, :store_dir=>proc{|post_logo, file| "post_logo/#{post_logo.created_at.strftime("%Y-%m-%d")}/#{post_logo.id}/logo" }

  def upload_to_aliyun
    return if !self.logo
    return if !File.exist?(self.logo.path)
    $connection.put("upload/post_logo/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self['logo']}", File.open(self.logo.path), {:content_type => self.logo.path.split(".").last.downcase == 'png' ? "image/png" : "image/jpeg"})
    $connection.put("upload/post_logo/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self['logo'].gsub('.', '_thumb200.')}", File.open(self.logo.thumb200.path), {:content_type => self.logo.thumb200.path.split(".").last.downcase == 'png' ? "image/png" : "image/jpeg"})
    $connection.put("upload/post_logo/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self['logo'].gsub('.', '_thumb400.')}", File.open(self.logo.thumb400.path), {:content_type => self.logo.thumb400.path.split(".").last.downcase == 'png' ? "image/png" : "image/jpeg"})
  end

  # 图片地址
  def logo_url
    logo.try(:url)
  end
  
  # 400x400缩略图地址,实际大小为395x395
  def logo_url_thumb400
    logo.try(:thumb400).try(:url)
  end
  
  # 171x147缩略图地址
  def logo_url_thumb200
    logo.try(:thumb200).try(:url)
  end

  def self.json_attrs
    [:id, :user_id, :post_id, :created_at]
  end
  
  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb120: 120x120缩略图地址
  # * logo_url_thumb400: 400x400缩略图地址, 实际大小为395x395
  # 
  def self.json_methods
    [:logo_url, :logo_url_thumb200, :logo_url_thumb400]
  end

  def as_json(options = {})
    options[:only] ||= PostLogo.json_attrs
    options[:methods] ||= PostLogo.json_methods
    super options
  end
end
