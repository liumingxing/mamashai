class EproductCategory < ActiveRecord::Base
  has_many :eproduct_tags, :dependent => :delete_all
  has_many :eproducts, :dependent => :delete_all
  has_many :tuans, :dependent => :delete_all
  serialize :label,Hash
  
  def self.grade_labels(product)
    category = product.eproduct_category
    return [[1,'价格'],[2,'质量'],[3,'外观']] if category.blank? or category.label.blank?
    label = category.label.select{|k,v|v.present?}.sort
    label
  end
end
