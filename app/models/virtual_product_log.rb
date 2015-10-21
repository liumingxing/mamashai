class VirtualProductLog < ActiveRecord::Base
  belongs_to :virtual_product
  belongs_to :user
  belongs_to :order_item
  
#  validates_uniqueness_of :code,:message=>"不能重复"
end
