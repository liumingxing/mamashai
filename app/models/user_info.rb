class UserInfo < ActiveRecord::Base
  # attr_accessible :title, :body

  def self.set_info(user_id, params)
  	user_info = UserInfo.find_by_user_id(user_id)
  	if user_info
  		user_info.update_attributes(params)
  	else
  		user_info = UserInfo.new(params)
  		user_info.user_id = user_id
  		user_info.save rescue nil
  	end
  end

  def self.get_info(user_id)
    UserInfo.find_by_user_id(user_id)
  end

  def self.add_comments_count(user_id)
    user_info = UserInfo.find_by_user_id(user_id)
    if user_info
      user_info.today_comments += 1
      user_info.save
    else
      user_info = UserInfo.new()
      user_info.user_id = user_id
      user_info.today_comments = 1
      user_info.save rescue nil
    end
  end

  def self.get_comments_count(user_id)
    user_info = UserInfo.find_by_user_id(user_id)
    if user_info
      return user_info.today_comments
    else
      return 0;
    end
  end
end
