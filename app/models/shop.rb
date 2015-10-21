class Shop < ActiveRecord::Base
  
  has_many :shop_products,:dependent => :delete_all
  
  upload_column :logo,:process => '140x140', :versions => { :thumb75 => "75x75" }
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :url
  validates_presence_of :deliver_policy
  validates_presence_of :discount_policy
  validates_presence_of :content
  validates_numericality_of :discount ,:allow_blank => true
  
  def self.find_hot_shops
    Shop.find(:all,:limit=>10,:order=>'shop_products_count desc')
  end
  
end
