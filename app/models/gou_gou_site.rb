class GouGouSite < ActiveRecord::Base
  belongs_to :gou
  belongs_to :gou_site, :counter_cache => 'gous_count'
  
end
