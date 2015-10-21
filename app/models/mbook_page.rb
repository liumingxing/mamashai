class MbookPage < ActiveRecord::Base
  upload_column :logo, :versions => {:thumb1000 => "1000x1000", :thumb400 => "400x400"}, :store_dir=>proc{|post, file| "mbook_page/#{post.created_at.strftime("%Y-%m-%d")}/#{post.id}/logo" }
  
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
    options[:only] ||= MbookPage.json_attrs
    options[:methods] ||= MbookPage.json_methods
    super options
  end
end
