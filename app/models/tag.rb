class Tag < ActiveRecord::Base
  belongs_to :category
  has_many :favorite_tags,:dependent => :delete_all
  has_many :age_tags,:dependent => :delete_all
  has_many :ages,:through=>:age_tags
  has_many :user_tags,:dependent => :delete_all
  has_many :users, :through => :user_tags


  has_many :book_tags, :dependent => :delete_all
  has_many :books,  :through => :book_tags

  validates_presence_of :name
  validates_uniqueness_of :name
  
  validates_length_of :name,:within => 2..20
  
  named_scope :named,lambda { |name|
    { :conditions => { :name => name } }
  }
  
  def category_name
   ( self.category.blank? ? APP_CONFIG['no_category'] : self.category.name )
  end
  
  ######################### actions ##########################
  
  def self.user_favorite_tags(user)
    Tag.find(:all,:conditions=>['favorite_tags.user_id=?',user.id],:joins=>'inner join favorite_tags on favorite_tags.tag_id = tags.id',:select=>'tags.*')
  end
  
  def self.create_post_content_tag(content)
    tag = nil
    tag_names = MamashaiTools::TextUtil.scan_post_tags(content)
    unless tag_names.blank?
      tag = Tag.find_by_name(tag_names[0])
      tag = Tag.create_tag(tag_names[0],1) unless tag
    end
    tag
  end 
  
  def self.create_tag(tag_name,posts_count)
    tag_name = MamashaiTools::TextUtil.gsub_dirty_words(tag_name.to_s)
    tag_name = MamashaiTools::TextUtil.gsub_not_tag_words(tag_name)
    Tag.create(:name=>tag_name,:posts_count=>posts_count)
  end
  
  def self.reward_tags
    Tag.find(:all,:conditions=>['id in (?)',Tag.reward_tag_ids])
  end
  
  def self.reward_tag_ids
    [3,148,149]
  end
  
  
  ########json#######
  # ==json_attrs 输出字段
  # * id: 话题ID
  # * name: 话题内容
  # * num: 该话题下微博数量
  # 
  def self.json_attrs
    %w{id name posts_count}
  end
  # ==json_methods 输出方法
  # * num: 该话题下微博数量
  # 
  # def self.json_methods
  #   %w{num}
  # end
  
  def as_json(options = {})
    options[:only] ||= Tag.json_attrs
    super options
  end

  def self.create_tag_from_post(tag_name)
    tag = Tag.find_by_name(tag_name)
    if tag
      tag.posts_count = tag.posts_count + 1
      tag.save
    else
      tag = Tag.create(:name => tag_name)
    end
    tag
  end
  
end
