class Gift < ActiveRecord::Base
  has_many :gift_gets,:dependent => :delete_all
  
  upload_column :logo,:process => '100x100' , :versions => {:thumb48 => "48x48"}
  
  validates_presence_of :name
  validates_presence_of :logo, :on=>:create
  
  def self.find_normal_gifts
    Gift.find(:all,:order=>'score asc',:conditions=>['score < 10 and id > 42'])
  end
  
  def self.find_advanced_gifts
    Gift.find(:all,:order=>'score asc',:conditions=>['score >= 10 '])
  end
  
  def self.json_attrs
    [:id, :name]
  end

  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址30x30
  #
  def self.json_methods
    %w{logo_url logo_url_thumb48}
  end
  
  # 图片地址
  def logo_url
    logo.try(:url)
  end

  # 缩略图地址
  def logo_url_thumb48
    logo.try(:thumb48).try(:url)
  end

  def as_json(options = {})
    options[:only] ||= Gift.json_attrs
    options[:methods] ||= Gift.json_methods
    super options
  end
  
end
