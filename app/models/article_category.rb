class ArticleCategory < ActiveRecord::Base
  acts_as_tree
  
  has_many :articles, :dependent => :destroy
  
  named_scope :gou_brand_article, :conditions => ["tp = '1'"]
  named_scope :gou_brand_story, :conditions => ["tp = '2'"]
  
  validates_presence_of :name, :message => "栏目名称不能为空"
  validates_uniqueness_of :name, :message => "栏目名称不能重复"
  validates_presence_of :tp, :message => "栏目类型不能为空"
  
  def article_count
    Article.count(:conditions=>"article_category_id = #{self.id}")
  end
end
