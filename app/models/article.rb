require 'elasticsearch/model'

class Article < ActiveRecord::Base
  belongs_to :mms_user, :class_name => "Mms::User"
  belongs_to :user
  belongs_to :article_category
  has_and_belongs_to_many :a_products
  has_one :article_content, :dependent => :destroy
  has_many :article_goods, :dependent => :delete_all
  has_many :article_comments, :dependent => :delete_all


  
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  
  belongs_to :article_brand,:foreign_key => :gou_brand_article_id, :class_name => "GouBrand"
  belongs_to :story_brand, :foreign_key => :gou_brand_story_id, :class_name => "GouBrand"
  validates_presence_of :title, :message => '资讯名称不能为空'
  validates_presence_of :article_category_id, :message => '资讯栏目名称不能为空'
  
  upload_column :logo ,:process => 'c200x200', :versions => {:thumb99 => "c100x100"}
  
  named_scope :publish, :conditions => ["state = '已发布' and articles.logo is not null"]

  def self.tiny_base_options
    {:theme => 'advanced',:language => 'zh-cn' , :browsers => %w{msie gecko},
      :theme_advanced_toolbar_location => "top",:theme_advanced_toolbar_align => "left",
      :theme_advanced_resizing => true,:theme_advanced_resize_horizontal => false,:paste_auto_cleanup_on_paste => true,
      :theme_advanced_buttons1 => %w{formatselect fontselect fontsizeselect bold italic underline strikethrough 
  separator justifyleft justifycenter justifyright indent outdent separator bullist numlist forecolor 
  backcolor separator link unlink image emotions fullscreen},
      :theme_advanced_buttons2 => [],:theme_advanced_buttons3 => [],
      :theme_advanced_fonts => "#{APP_CONFIG['tiny_fonts']}Arial=arial,helvetica,sans-serif;Comic Sans MS=comic sans ms,sans-serif;Courier New=courier new,courier;Tahoma=tahoma,arial,helvetica,sans-serif;Times New Roman=times new roman,times;Verdana=verdana,geneva;Webdings=webdings;Wingdings=wingdings,zapf dingbats",
      :document_base_url => '/',   
      :relative_urls => false,
      :remove_script_host => false, 
      :plugins => %w{contextmenu inlinepopups paste emotions fullscreen advimage},
      :handle_event_callback=>"ctl_ent"}
  end
  
  def self.tiny_form_options
    {:theme => 'advanced',:language => 'zh-cn' , :browsers => %w{msie gecko},
      :theme_advanced_toolbar_location => "top",:theme_advanced_toolbar_align => "left",
      :theme_advanced_resizing => true,:theme_advanced_resize_horizontal => false,:paste_auto_cleanup_on_paste => true,
      :theme_advanced_buttons1 => %w{formatselect fontselect fontsizeselect bold italic underline strikethrough 
  separator justifyleft justifycenter justifyright indent outdent },
      :theme_advanced_buttons2 => [%w{ bullist numlist forecolor 
  backcolor separator link unlink image media emotions charmap hr | fullscreen code}],:theme_advanced_buttons3 => [],
      :theme_advanced_fonts => "#{APP_CONFIG['tiny_fonts']}Arial=arial,helvetica,sans-serif;Comic Sans MS=comic sans ms,sans-serif;Courier New=courier new,courier;Tahoma=tahoma,arial,helvetica,sans-serif;Times New Roman=times new roman,times;Verdana=verdana,geneva;Webdings=webdings;Wingdings=wingdings,zapf dingbats",
      :document_base_url => '/',   
      :relative_urls => false,
      :remove_script_host => false, 
      :plugins => %w{contextmenu inlinepopups paste emotions fullscreen advimage},
      :handle_event_callback=>"ctl_ent"}
  end
  
  def self.tiny_advance_options
    {:theme => 'advanced', :language => 'zh-cn' ,  :browsers => %w{msie gecko},
      :theme_advanced_toolbar_location => "top", :theme_advanced_toolbar_align => "left",
      :theme_advanced_resizing => true, :theme_advanced_resize_horizontal => false,
      :paste_auto_cleanup_on_paste => true,
      :theme_advanced_buttons1 => %w{formatselect fontselect fontsizeselect bold italic underline  
      separator justifyleft justifycenter justifyright indent outdent separator bullist numlist forecolor 
      backcolor },
      :theme_advanced_buttons2 => %w{undo redo cut copy paste pasteword | search replace | 
     table image media emotions charmap separator link unlink removeformat | fullscreen code},
      :theme_advanced_buttons3 => [],
      :theme_advanced_fonts => "#{APP_CONFIG['tiny_fonts']}Arial=arial,helvetica,sans-serif;Comic Sans MS=comic sans ms,sans-serif;Courier New=courier new,courier;Tahoma=tahoma,arial,helvetica,sans-serif;Times New Roman=times new roman,times;Verdana=verdana,geneva;Webdings=webdings;Wingdings=wingdings,zapf dingbats",
      :document_base_url => '/',   
      :relative_urls => false,
      :remove_script_host => false,  
      :plugins => %w{contextmenu inlinepopups paste emotions fullscreen advimage table media searchreplace insertdatetime} }
  end

  def post
    Post.find_by_from_and_from_id('article', self.id)
  end
  
  def article_category_name
    article_category.name
  end

  ########json##########
  # ==json_attrs 输出字段
  # * id: 资讯ID
  # * article_category_id: 分类id
  # * title: 标题
  # * view_count: 浏览数目
  # * created_at: 创建时间
  # * author: 作者
  # * article_goods_count: 好评数
  #
  def self.json_attrs
    [:id, :article_category_id, :title, :view_count, :created_at, :author, :article_goods_count, :tuiguang_text, :tuiguang_url]
  end

  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址30x30
  #
  def self.json_methods
    %w{article_category_name logo_url logo_url_thumb99 article_comments_count}
  end
  
  # 图片地址
  def logo_url
    logo.try(:url)
  end

  # 缩略图地址
  def logo_url_thumb99
    logo.try(:thumb99).try(:url)
  end

  def as_json(options = {})
    if options[:stay]
      only = Article.attribute_names
      only.delete("logo")
      super(:only=>only)
    else
      options[:only] ||= Article.json_attrs
      options[:methods] ||= Article.json_methods
      super options
    end
  end

  def as_indexed_json(options={})
    options[:stay] = true
    as_json(options)
  end
end

#Article.__elasticsearch__.client = Elasticsearch::Client.new host: 'www.mamashai.com'
