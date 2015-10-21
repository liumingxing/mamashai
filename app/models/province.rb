class Province < ActiveRecord::Base
  has_many :cities
  has_many :users

  def self.cache_find(id)
  	return nil if !id

  	begin
      c = $cache.get("province_#{id}")
    rescue Memcached::NotFound => e
      c = Province.find_by_id(id)
      $cache.set("province_#{id}", c)
    rescue
      c = Province.find_by_id(id)
    end
    return c
  end
end
