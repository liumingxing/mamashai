class GouCategory < ActiveRecord::Base
  has_many :gous, :dependent => :delete_all
  has_many :tuans, :dependent => :delete_all
  serialize :label,Hash
  
  validates_presence_of(:name, :message => "商品分类名称不能为空")
  validates_uniqueness_of(:name, :message => "商品分类名称唯一")
  
  named_scope :publish, :conditions => ['gou_categories.state IS NOT NULL']
  
  DEFAULT_LABELS = [[1,'价格'],[2,'质量'],[3,'外观']]
  DEFAULT_BRAND_LABELS = [[1,'知名度'],[2,'满意度'],[3,'忠诚度']]
  
  def self.grade_labels(product=nil)
    return DEFAULT_BRAND_LABELS if product.is_a?(GouBrand)
    if product.is_a?(GouCategory)
      category = product
    else
      category = product.try(:gou_category)
    end
    return  DEFAULT_LABELS if category.blank? or category.label.blank?
    label = category.label.select{|k,v|v.present?}.sort
    return  DEFAULT_LABELS if label.blank?
    label
  end
  
  state_machine :initial => :unpublish do
    state :unpublish
    state :publish
    
    event :publish do
      transition :unpublish => :publish
    end
    
    event :unpublish do
      transition :publish => :unpublish
    end
    
  end
  
  def self.get_category(name)
    return if name.blank?
    category = GouCategory.last(:conditions=>["brand_item like ?","%"+name+"%"])
    return category
  end
  
#  def update_categories
#    file = File.new(File.join(RAILS_ROOT,"public","categories.html"))
#    builder = Nokogiri::HTML::Builder.new do |doc|
#      doc.div(:id=>"css_sidebar") do
#        doc.div.panel do 
#          doc.div.panel_title do 
#            doc.text "商品分类"
#          end
#        end
#      end
#      
#    end
#    builder.to_html
#  end
  
end
