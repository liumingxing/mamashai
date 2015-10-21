class EproductTag < ActiveRecord::Base
  belongs_to :eproduct_category
  has_many :eproducts
  
  def self.top_tags
    EproductTag.find(:all,:conditions=>"parent_id is null",:order=>"id asc")
  end
  
  def sub_tags
    EproductTag.find(:all,:conditions=>["parent_id = ?",self.id],:order=>"id asc")
  end
end
