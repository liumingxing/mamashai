class WeekTag < ActiveRecord::Base
  belongs_to :age
  upload_column :logo ,:process => '800x600', :versions => {:thumb90 => "c90x90"}
  named_scope :normal, :conditions=>"hide = 0"
  has_one :tao_topic, :foreign_key=>"title", :primary_key=>"short_tag_name"

  #def tao_topic
  #  TaoTopic.find_by_title(self.short_tag_name)
  #end

  # 默认图片地址450x450
  def logo_url
    logo.try(:url)
  end
  
  # 90x90 缩略图地址
  def logo_url_thumb90
    logo.try(:thumb90).try(:url)
  end

  def tag_name
    self.short_tag_name
  end
  
  def self.json_attrs
    [:id, :created_at, :updated_at, :week_count, :description, :summary, :short_tag_name, :tag_name]
  end
  
  def self.json_methods
    %w{logo_url logo_url_thumb90}
  end
  
  def as_json(options = {})
    return 'null' if self.blank?
    options[:only] ||= AgeTag.json_attrs
    options[:methods] = (options[:methods] || []) + AgeTag.json_methods
    #options[:include] = [:tao_topic]
    options[:include] ||= {:tao_topic=>{:only => TaoTopic.json_attrs, :methods=>TaoTopic.json_methods}}
    super options
  end
end
