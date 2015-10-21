class City < ActiveRecord::Base
  belongs_to :province
  has_many :users
  
  def add_on_fright_fee
    return FrightProfile.find(1).fee if self.province_id==1
    return FrightProfile.find(2).fee
  end

  def self.cache_find(id)
  	return nil if !id

  	begin
      c = $cache.get("city_#{id}")
    rescue Memcached::NotFound => e
      c = City.find_by_id(id)
      $cache.set("city_#{id}", c)
    rescue
    	c = City.find_by_id(id)
    end
    return c
  end
  
end
