class Adv < ActiveRecord::Base
  upload_column :logo, :versions => {:thumb200 => "c200x200", :thumb100=> "c160x160", :thumb50=>"c50x50"}
  validates_presence_of :logo, :message=>"必须上传图片"
  validates_presence_of :link, :message=>"请输入链接网址"  
  
  def self.get(tp)
    Adv.find(:all, :conditions=>"tp=#{tp} and hide = 0 ", :order=>"updated_at desc")
  end
  
  def self.json_attrs
    [:id, :link, :price, :desc]
  end
  
  def self.json_methods
    %w{logo_url logo_thumb200 logo_thumb100 logo_thumb50}
  end
  
  def url
    self.link
  end
  
  def logo_url
    self.logo.url
  end
  
  def logo_thumb200
    self.logo.thumb200.url
  end
  
  def logo_thumb100
    self.logo.thumb100.url
  end
  
  def logo_thumb50
    self.logo.thumb50.url
  end
  
  def as_json(options = {})
    options[:only] ||= Adv.json_attrs
    options[:methods] ||= Adv.json_methods
    super options
  end
end

