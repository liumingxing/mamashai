class Mbook < ActiveRecord::Base
  belongs_to :user
  
  upload_column :logo, :versions => {:thumb171 => "171x236", :thumb342 => "342x472"}, :store_dir=>proc{|post, file| "mbook/#{post.created_at.strftime("%Y-%m-%d")}/#{post.id}/logo" }
  
  def self.json_attrs
    [:id, :name, :json, :created_at, :updated_at]
  end

  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址30x30
  #
  def self.json_methods
    %w{user logo_url logo_url_thumb171 logo_url_thumb342}
  end
  
  # 图片地址
  def logo_url
    logo.try(:url)
  end

  # 缩略图地址
  def logo_url_thumb171
    logo.try(:thumb171).try(:url)
  end

  def logo_url_thumb342
    logo.try(:thumb342).try(:url)
  end
  
  def as_json(options = {})
    options[:only] ||= Mbook.json_attrs
    options[:methods] ||= Mbook.json_methods
    super options
  end
end
