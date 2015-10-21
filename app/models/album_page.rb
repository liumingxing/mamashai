class AlbumPage < ActiveRecord::Base
	after_create :upload_to_aliyun

  upload_column :logo, :process => '1024x1024', :versions => {:thumb400 => "400x400"}, :store_dir=>proc{|post, file| "album_page/#{post.created_at.strftime("%Y-%m-%d")}/#{post.id}/logo" }

  def upload_to_aliyun
    return if !self.logo
    return if !File.exist?(self.logo.path)
    $connection.put("upload/album_page/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self['logo']}", File.open(self.logo.path), {:content_type => self.logo.path.split(".").last.downcase == 'png' ? "image/png" : "image/jpeg"})
    $connection.put("upload/album_page/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self['logo'].gsub('.', '_thumb400.')}", File.open(self.logo.thumb400.path), {:content_type => self.logo.thumb400.path.split(".").last.downcase == 'png' ? "image/png" : "image/jpeg"})
  end

  def self.json_attrs
    [:id, :created_at, :updated_at]
  end

  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址30x30
  #
  def self.json_methods
    %w{logo_url logo_url_thumb400}
  end
  
  # 图片地址
  def logo_url
    logo.try(:url)
  end

  # 缩略图地址
  def logo_url_thumb400
    logo.try(:thumb400).try(:url)
  end
  
  def as_json(options = {})
    options[:only] ||= AlbumPage.json_attrs
    options[:methods] ||= AlbumPage.json_methods
    super options
  end
end
