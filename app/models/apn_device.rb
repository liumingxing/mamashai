class ApnDevice < ActiveRecord::Base
	#belongs_to :user

	def user
		if self.user_id
			return User.find_by_id(self.user_id)
		else
			User.find_by_email(self.alias)
		end
	end

	def last_message
		@message ||= ApnMessage.find(:first, :conditions=>"user_id = #{self.user_id} and tp = #{self.tp}", :order=>"id desc")
		return @message
	end

	def self.send_apn(tp, device_token, text, badge, silent=false, extras=nil)
		if tp <= 3
			apps = {1=>"bbrl_ios", 2=>"yun_ios", 3=>"yu_ios"}

			n = Rpush::Apns::Notification.new
	        n.app = Rpush::Apns::App.find_by_name(apps[tp])
	        n.device_token = device_token
	        n.alert = text[0, 128]
	        n.sound = silent ? 'silent.wav' : 'default'
	        n.badge = badge if badge.to_i > 0
	        n.attributes_for_device = extras
	        if n.alert == '同步内容到微信，获得1个晒豆。'
	        	n.deliver_after = Time.new.since(3.minutes)
	        end
	        n.save! rescue nil
	    else
	    	apps = {4=>"bbrl_android", 5=>"yun_android", 6=>"yu_android"}
	    	n = Rpush::Gcm::Notification.new
			n.app = Rpush::Gcm::App.find_by_name(apps[tp])
			n.registration_ids = [device_token]
			n.data = { message: text, title: '宝宝日历提醒' }
			if n.alert == '同步内容到微信，获得1个晒豆。'
	        	n.deliver_after = Time.new.since(3.minutes)
	        end
			n.save!
	    end
	end

	def self.broadcast_apn(tp, text, extras=nil)
		#发ios推送
		apps = {1=>"bbrl_ios", 2=>"yun_ios", 3=>"yu_ios"}
		offset = 0
		data = extras ? extras.to_json.to_s : nil
		rpush_apps = Rpush::Apns::App.all(:conditions=>"name like '#{apps[tp]}_broadcast%'")
		devices = ApnDevice.all(:conditions=>"tp = #{tp} and active = 1", :order=>"id", :limit=>2000, :offset=>offset)
		while devices.size > 0
			inserts = []
			now = Time.new
			for device in devices
				sound = device.silent ? 'silent.wav' : 'default'
			    begin
				    inserts.push "(#{rpush_apps[rand(rpush_apps.size)].id}, 'Rpush::Apns::Notification', '#{device.device_token}', '#{text}', '#{sound}', #{data ? "'" + data + "'" : "null"}, '#{now.to_s(:db)}', '#{now.to_s(:db)}')"
				rescue
				end
			end			

			sql = "INSERT INTO rpush_notifications (`app_id`, `type`, `device_token`, `alert`, `sound`, `data`, `created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
			Rpush::Apns::Notification.connection.execute sql rescue nil
			
			#for device in devices
			#	next if device.device_token.to_s.size == 0
			#	begin
			#		n = Rpush::Apns::Notification.new
			#        n.app = Rpush::Apns::App.find_by_name("#{apps[tp]}_broadcast#{rand(18) + 1}")
			#        n.device_token = device.device_token
			#        n.alert = text
			#        n.sound = device.silent ? 'silent.wav' : 'default'
			#        n.attributes_for_device = extras
			#        n.save!
		    #   rescue
		    #    end
			#end
			offset += 2000
			devices = ApnDevice.all(:conditions=>"tp = #{tp} and active = 1", :order=>"id", :limit=>2000, :offset=>offset)
		end
	end
end
