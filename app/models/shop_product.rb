class ShopProduct < ActiveRecord::Base
  
  belongs_to :shop, :counter_cache => true
  belongs_to :product, :counter_cache => true
  has_many :product_orders,:dependent => :delete_all
  
  validates_presence_of :name
  validates_presence_of :url
 # validates_presence_of :content
  validates_presence_of :shop_id
  validates_presence_of :product_id
  
end
