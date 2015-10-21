class CouponCategory < ActiveRecord::Base
  validates_presence_of :name,:money,:logo,:score,:limit_time,:use,:message=>"不能为空"
  has_many :coupons, :dependent => :delete_all
  upload_column :logo ,:process => '220x150', :versions => {:thumb110=>"c110x75"}
  
  STATE_TYPES=[['未开启',false],['开启',true]]
  CATEGORY_TYPES=[['其他',0],['团购',1],['个性照片书',2]]
  
  def self.state_types
    STATE_TYPES
  end
  
  def self.category_types
    CATEGORY_TYPES
  end
  
end
