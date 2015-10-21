class ProductOrder < ActiveRecord::Base
  
  belongs_to :product
  belongs_to :shop_product
  belongs_to :user
  
  validates_presence_of :shop_product_id
  validates_presence_of :user_id
end
