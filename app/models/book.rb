class Book < ActiveRecord::Base
  belongs_to :mms_user, :class_name => "Mms::User"
  belongs_to :user, :class_name => "User"
  belongs_to :user_translator, :class_name => "User", :foreign_key => "translator_id"
  has_many :book_malls,:dependent => :destroy
  has_many :book_subjects, :dependent => :destroy
  has_many :subjects, :through => :book_subjects
  has_many :book_tags, :dependent => :destroy
  has_many :tags, :through => :book_tags

  has_many :book_visits
  has_many :users, :through => :book_visits

  has_one :book_content, :dependent => :destroy
#  has_many :article_goods, :dependent => :delete_all
#  has_many :article_comments, :dependent => :delete_all
  belongs_to :book_brand,:foreign_key => :brand_id, :class_name => "GouBrand"
#  belongs_to :story_brand, :foreign_key => :gou_brand_story_id, :class_name => "GouBrand"
  validates_presence_of :book_name, :message => '图书名称不能为空'
#  validates_presence_of :article_category_id, :message => '资讯栏目名称不能为空'

  upload_column :logo ,:process => '800x600', :versions => {:thumb99 => "c99x148",:thumb66 => "c66x101"}

  named_scope :publish, :conditions => ["state = '已发布' and books.logo is not null"], :order => "books.created_at DESC"



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
    [:id, :article_category_id, :title, :view_count, :created_at, :author, :article_goods_count]
  end

  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址30x30
  #
  def self.json_methods
    %w{article_category_name logo_url logo_url_thumb99}
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
    options[:only] ||= Article.json_attrs
    options[:methods] ||= Article.json_methods
    super options
  end

  def packaging
    "#{self.paperback}：#{self.book_pages}"
  end

  def brand
    "待实现"#"#{self.book_brand.name} <a href='http://#{self.book_brand.link}' target='_blank'>#{self.book_brand.link}</a>"
  end

  def book_translator
    #::User.find_by_id(self.translator_id).name if self.translator_id
    self.user_translator.name
  end

  # 图片地址
  def logo_url
    logo.try(:url)
  end

  # 缩略图地址
  def logo_url_thumb99
    logo.try(:thumb99).try(:url)
  end

  def self.get_book_recommend
    Book.first(:conditions => ["state = ?","已发布"], :order => "created_at desc")
  end

  def series_book
    Book.first(:order => "id desc", :conditions => [" id <> ? and series_book_name like ",self.id, "%#{book.book_name}%"])
  end

  def content
    self.book_content.content
  end

  def book_tag_names
    tags = self.tag_names.split(" ").unshift(self.book_name)
    tags
  end

  def add_book_visit_count
    self.view_count = self.view_count + 1
    self.save
  end

  def create_book_visit(user)
    book_visit = self.users.all(:conditions => ["user_id = ?", user.id]).first
    self.users << user unless book_visit
  end

  def show_book_active
    actives = []
    actives = self.book_active.split("$")  unless self.book_active.blank?
    actives.collect{|active| [active.split("#")[0],active.split("#")[1]]}
  end

  def show_unite_recommend
    recommends = []
    recommends = self.unite_recommend.split("$")  unless self.unite_recommend.blank?
    recommends.collect{|recommend| recommend.split(" ")}
  end

  def get_series_book
    Book.find_by_id(self.series_book_ids)
  end

  def show_book_author_type
    txt = {"zz"=> "作者", "yz" => "译者"}
    txt[self.author_type]
  end
end