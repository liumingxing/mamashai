require 'mamashai_tools/tool_util'
include MamashaiTools

namespace :mamashai do
  desc "送宝宝日历推送"
  task :send_bbrl_tip  => [:environment] do
    #发入星星榜推送
    max = BbrlStar.first(:select=>"max(num) as n")
    stars = BbrlStar.all(:conditions=>"num = #{max['n']}")
    for star in stars
        MamashaiTools::ToolUtil.push_aps(star.user_id, "亲，恭喜您入选今天的星星榜，成为万人瞩目的星妈星爸：）")
    end

    now = Time.new
    offset = 0;
    devices = ApnDevice.find(:all, :order=>"id", :conditions=>"active=1", :limit=>1000, :offset=>offset)
    while devices.size > 0
    	for device in devices
            next if !device.active                      #已经不活跃了

    		next if !device.user						#找不到用户了
    		
    		next if device.user.user_kids.size == 0	#没有孩子

            #一个月没登录了，不推送
            next if device.user.last_login_at && device.user.last_login_at < now.ago(30.days)

    		kid = device.user.user_kids.last
    		next if !kid || !kid.birthday						#孩子没填生日

			distance = MamashaiTools::ToolUtil.calc_distance(kid.birthday)	

    		tips = CalEnd::Tip.find(:all, :conditions=>"distance=#{distance} and title is not null and title <> ''", :order=>"id")
    		tips.each_with_index{|tip, index|
                next if distance == MamashaiTools::ToolUtil.calc_distance(kid.birthday + 1 + index)
                MamashaiTools::ToolUtil.push_aps(device.user_id, tip.t + "：" + tip.title, device.device_token)
		        break;
                #puts "#{tip.t} #{device.user.id} --- #{kid.birthday} --- #{distance}  --- #{tip.title}\n"
            }
    	end
    	offset += 1000
    	devices = ApnDevice.find(:all, :order=>"id", :conditions=>"active=1", :limit=>1000, :offset=>offset)
    end

  end
end
