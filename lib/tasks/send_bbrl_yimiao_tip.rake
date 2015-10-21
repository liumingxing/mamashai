namespace :mamashai do
  desc "送宝宝日历疫苗推送"
  task :send_bbrl_yimiao_tip  => [:environment] do
  	tips = {1=>"乙型肝炎疫苗（第二次）",
  			2=>"脊髓灰质炎糖丸（第一次）",
  			3=>"脊髓灰质炎糖丸（第二次），无细胞百白破疫苗（第一次）",
  			4=>"脊髓灰质炎糖丸（第三次），无细胞百白破疫苗（第二次）",
  			5=>"无细胞百白破疫苗（第三次）",
  			6=>"乙型肝炎疫苗（第三次），流脑疫苗（第一次）",
  			8=>"麻风二联疫苗（第一次）",
  			9=>"流脑疫苗（第二次）",
  			12=>"乙脑减毒疫苗（第一次）",
  			18=>"甲肝疫苗（第一次），无细胞百白破疫苗（第四次），麻风腮疫苗（第一次）",
  			24=>"乙脑减毒疫苗（第二次），甲肝疫苗（第二次）",
  			36=>"A+C流脑疫苗（加强）",
  			48=>"脊灰疫苗（第四次）",
  			71=>"无细胞百白破疫苗（加强），麻风腮疫苗（第二次）"}
    offset = 0;
    devices = ApnDevice.find(:all, :order=>"id", :limit=>1000, :offset=>offset)
    while devices.size > 0
    	for device in devices
    		next if !device.active
        next if !device.user_id 
        next if !device.user						#找不到用户了
    		
    		next if !device.user.user_kids.size == 0	#没有孩子

    		kid = device.user.user_kids.last
    		next if !kid || !kid.birthday						#孩子没填生日

			  distance = calc_distance(kid.birthday.tomorrow)
			  next if distance[0] == -1              				#孩子没出生
			  next if distance[1] > 0								#不是整月

    		if tips[distance[0]]
    			MamashaiTools::ToolUtil.push_aps(device.user_id, device.user.user_kids.last.name + "最近该打疫苗了："+ tips[distance[0]], device.device_token)
    		end

    		
    	end
    	offset += 1000
    	devices = ApnDevice.find(:all, :order=>"id", :limit=>1000, :offset=>offset)
    end

  end

  def calc_distance(birthday)
	today = Date.today
    distance = 0
    if birthday <= today					#已出生
    	year  = today.year - birthday.year
    	month = today.month - birthday.month
    	date  = today.day - birthday.day
    	if month < 0
    		year -= 1
    		month += 12
    	end

    	if (date < 0)
    		month -= 1
    		date += 30
    	end

    	if date >= 28
    		date = 27
    	end
    	return year*12 + month, date
    else										# 未出生
    	return -1, -1
    end
  end
end