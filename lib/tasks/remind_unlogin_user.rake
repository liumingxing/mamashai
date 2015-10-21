namespace :mamashai do
  desc "提醒一周内没有记录的用户来记录"
  task :remind_unlogin_user  => [:environment] do
    jpush_keys = %w(b789c8ed387ca31a1569c932:78ab7b77f32b35deccf4b847 9c75b77425cb280bc1c975fe:e2917386120a007763cb468e 8ea7cf97ac67608ba65c2db7:75c7d17c756279565ceb2b6f)
    apps = {1=>"bbrl_ios", 2=>"yun_ios", 3=>"yu_ios"}
    texts = ["记录宝宝的成长瞬间，把时间留住。今天你记了吗！",
             "宝宝长大后要听你讲小时候的故事，好记性不如好记录！",
             "一孕傻三年，啥都记不清。要想永不忘，现在就记录！"]
    text = texts[0]
    case Time.now.day
    when 0..10
        text = texts[0]
    when 11..20
        text = texts[1]
    when 20..31
        text = texts[2]
    else
        text = texts[0]
    end
    p text

    offset = 0
    devices = ApnDevice.all(:limit=>1000, :offset=>offset, :conditions=>"active = 1 and user_id is null ", :order=>"id asc")
    while devices.size > 0
    	for device in devices
            next if !device.device_token || !device.tp
            next if device.device_token.size < 1
            p device.id.to_s + " " + device.device_token
            if device.tp >= 4 && device.device_token.size < 100   #极光推送
                if device.device_token.length < 20            #极光推送
                    result = MamashaiTools::ToolUtil.fork_command %Q!curl --connect-timeout 10 -X POST -v https://api.jpush.cn/v3/push -H "Content-Type: application/json" -u "#{jpush_keys[device.tp - 4]}" -d '{"platform":"android","audience":{"registration_id" : ["#{device.device_token}"]},"notification":{"alert":"#{text}"}}'!
                end
            else                                            #苹果apn推送
                next if device.device_token.size > 100
                n = Rpush::Apns::Notification.new
                n.app = Rpush::Apns::App.find_by_name("#{apps[device.tp]}_broadcast#{rand(10) + 1}")
                n.device_token = device.device_token
                n.alert = text
                n.sound = 'default'
                n.attributes_for_device = {tp: 'remind'}
                n.save! rescue nil
                #ApnDevice.send_apn(device.tp, device.device_token, text, 0)
            end
    	end
    	offset += 1000
    	devices = ApnDevice.all(:limit=>1000, :offset=>offset, :conditions=>"active = 1 and user_id is null", :order=>"id asc")
    end
  end
end
