class UserLocation < ActiveRecord::Base
  # attr_accessible :title, :body
  def self.set_location(user_id, province_id, city_id)
  	location = UserLocation.find_by_user_id(user_id)
  	location = UserLocation.new(:user_id => user_id) if !location
  	location.province_id = province_id
  	location.city_id	 = city_id
  	location.save
  end
end
