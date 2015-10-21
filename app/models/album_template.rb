class AlbumTemplate < ActiveRecord::Base
  upload_column :logo, :versions => {:thumb150 => "150x150", :thumb300 => "300x300", :thumb600 => "600x600"}, :store_dir=>proc{|post, file| "album_template/#{post.created_at.strftime("%Y-%m-%d")}/#{post.id}/logo" }

  def self.json_attrs
    [:id, :name]
  end

  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址30x30
  #
  def self.json_methods
    %w{user logo_url_thumb150 logo_url_thumb300 logo_url_600}
  end

  # 缩略图地址
  def logo_url_thumb150
    logo.try(:thumb150).try(:url)
  end

  def logo_url_thumb300
    logo.try(:thumb300).try(:url)
  end
  
  def logo_url_thumb600
    logo.try(:thumb600).try(:url)
  end

  def as_json(options = {})
    options[:only] ||= AlbumTemplate.json_attrs
    options[:methods] ||= AlbumTemplate.json_methods
    super options
  end
end
