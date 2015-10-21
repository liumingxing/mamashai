class PostLocation < ActiveRecord::Base
	#after_create :make_logo

	def make_logo
		token = Weibotoken.get('sina', "baby_calendar")
    	user_weibo = UserWeibo.find(:first, :conditions=>"tp=#{token.tp} and expire_at > #{Time.new.to_i}", :order=>"id desc")
    	text = `curl 'https://api.weibo.com/2/location/base/get_map_image.json?source=#{token.token}&access_token=#{user_weibo.access_token}&center_coordinate=#{self.longitude}%2C#{self.latitude}&size=480x200'`
		json = JSON.parse(text)
		self.logo = json["map"][0]["image_url"]
		self.save
	end
end
