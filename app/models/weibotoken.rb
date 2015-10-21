class Weibotoken < ActiveRecord::Base
  def self.get(platform, from_str=nil)
    from_str = "lama_iphone" if from_str == 'lama_baidu'
    from_str = nil if from_str == "lama_web"
    
    if from_str
      token = Weibotoken.find(:first, :conditions=>"platform='#{platform}' and from_str='#{from_str}'")
      #p token
      if !token
        if from_str.index("lama")
          token = Weibotoken.find(:first, :conditions=>"platform='#{platform}' and from_str='lama_web'")
        elsif %w(calendar shanguang fayu yingyang zaojiao caiyi biaoqing bbyulu shijian wenzi jiance video taotaole).include?(from_str)
          token = Weibotoken.find(:first, :conditions=>"platform='#{platform}' and from_str='baby_calendar'")
        else
          token = Weibotoken.find(:first, :conditions=>"platform='#{platform}'")
        end        
      end
    else
      token = Weibotoken.find(:first, :conditions=>"platform='#{platform}'")
    end
    
    return token
  end
end
