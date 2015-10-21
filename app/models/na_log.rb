class NaLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :gou
  
  def self.check_user(user_id)
    count = NaLog.count(:conditions=>"user_id = #{user_id} and created_at > '#{Time.new.to_date} 0:0:0' and created_at < '#{Time.new.to_date} 23:59:59'")
    if count < 3
      true
    else
      false
    end
  end
end
