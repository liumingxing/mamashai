class AgeWeekTag < ActiveRecord::Base
  belongs_to :age
  upload_column :logo ,:process => '800x600', :versions => {:thumb90 => "c90x90"}

  # 默认图片地址450x450
  def logo_url
    logo.try(:url)
  end
  
  # 90x90 缩略图地址
  def logo_url_thumb90
    logo.try(:thumb90).try(:url)
  end

  def tag_name
    self.tag.name
  end
  
  def self.json_attrs
    [:id, :age_id, :tp, :created_at, :updated_at, :week_count, :description, :summary, :short_tag_name]
  end
  
  def self.json_methods
    %w{logo_url logo_url_thumb90 tag_name}
  end
  
  def as_json(options = {})
    return 'null' if self.blank?
    options[:only] ||= AgeTag.json_attrs
    options[:methods] = (options[:methods] || []) + AgeTag.json_methods
    super options
  end
end
