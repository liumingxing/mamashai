
module MamashaiTools
  class ToolUtil
    def initialize
    end
    
    def self.has_unread_infos(user)
      user.unread_comments_count>0 || user.unread_messages_count>0 || user.unread_gifts_count>0 || user.unread_atme_count>0 || user.unread_fans_count>0 || user.unread_claps_count>0 || user.unread_favorites_count>0
    end
    
    def self.add_unread_sys_infos
      User.update_all(["unread_messages_count=(unread_messages_count+1)"],["id<>?",User.mms_user_id])
    end
    
    def self.add_unread_infos(tp,params)
      if tp == :create_comment 
        return if params[:post_user].id == params[:comment_user].id
        params[:post_user].unread_comments_count += 1 unless params[:post].score 
        params[:post_user].save(:validate=>false) 
      end

      if tp == :create_clap
        params[:user].unread_claps_count += 1
        params[:user].save(:validate=>false)
      end
      
      if tp == :create_follow_user
        params[:user].unread_fans_count += 1
        params[:user].save(:validate=>false)
      end
      
      if tp == :create_favorite_post
        params[:user].unread_favorites_count += 1
        params[:user].save(:validate=>false)
      end
      
      if tp == :create_gift_get
        params[:user].unread_gifts_count += 1 
        params[:user].save(:validate=>false)
        user_profile = params[:user].user_profile
        if user_profile && user_profile.notify_ignores 
          notify_ignores = user_profile.notify_ignores.split('|')
          unless notify_ignores.include?('email_gift')
            #Mailer.deliver_email(Mailer.notify_gift(params[:user]))
          end
          if !params[:user].mobile.blank? && !notify_ignores.include?('sms_gift') && user_profile.user_actions.split('|').include?('fetion_invite')
            MamashaiTools::HttpUtil.send_fetion_message(params[:user].mobile,APP_CONFIG['sms_notify_gift'])
          end
        end
      end
      
      if tp == :create_message_post
        params[:user].unread_messages_count += 1
        params[:user].save(:validate => false)
        user_profile = params[:user].user_profile
        if user_profile and user_profile.notify_ignores.present?
          notify_ignores = user_profile.notify_ignores.split('|')
        else
          notify_ignores = []
        end
        unless notify_ignores.include?('email_message')
          #Mailer.deliver_email(Mailer.notify_message(params[:user]))
        end

        if !params[:user].mobile.blank? && !notify_ignores.include?('sms_message') && user_profile.user_actions.split('|').include?('fetion_invite')
          MamashaiTools::HttpUtil.send_fetion_message(params[:user].mobile,APP_CONFIG['sms_notify_message'])
        end
      end
      
      if tp == :create_forward_post
        params[:user].unread_atme_count += 1
        params[:user].save(:validate=>false)
        MamashaiTools::ToolUtil.update_users_atme_count(params[:post].content,params[:user].name)
      end
      
    end
    
    def self.update_users_atme_count(content,except_name=nil)
      names = MamashaiTools::TextUtil.scan_atme_names(content)
      return if names.blank?
      names.uniq!
      names.delete(except_name) if except_name.present?
      names.each do |name|
        user = User.find_by_name(name)
        if user
          user.unread_atme_count += 1
          user.save(:validate=>false)
        end
      end
    end 
    
    def self.update_users_comment_atme_count(content)
      names = MamashaiTools::TextUtil.scan_atme_names(content)
      return if names.blank?
      names.uniq!
      names.each do |name|
        user = User.find_by_name(name)
        if user
          user.unread_comments_count += 1
          user.save(:validate=>false)
        end
      end
    end 
    
    def self.clear_unread_infos(user,tp)
      user[tp] = 0
      user.save(:validate=>false)
    end

    def self.fork_command(command)
      c = CommandQueue.new 
      c.command = command 
      if command.index("同步内容到微信")
        c.created_at = Time.new.since(3.minutes)
      end
      c.save

      return "save"
      #return `#{command}`

      
      #pid = Process.fork{
      #   `#{command}`
      #}
      #Process.detach(pid)
      #exit if pid.nil?
    end

    #发一个推送
    #user_id : 接收人
    #text : 发送文本
    def self.push_aps(user_id, text, extras=nil)
      #text = MamashaiTools::TextUtil.truncate(text, 85)
      text = text.strip

      if text.mb_chars.size > 70
         text = text.mb_chars[0, 70] + "..."
      end
      text = text.gsub("'", "")

      user = User.find_by_id(user_id)
      return if !user

      application_ids = %w(nJwnXAVGWQRlDU4nyihzPcrDkSR2XoUil3UfxZsk ghYhOyMFv2huU7UxMuo5mdoAS20VpIyyYBlUNjlc UnLOphymTe6HhVsX1H8qJriGeOfpbzWfEwb4pQhp)
      rest_keys = %w(psYNG1xYcd0k8IExR4RTlnYd2McjqbCgcaTwwyNK wS69Bvdb5cXy4mrWjiJpuc9k5MWBuCavXJTpdEcT ORr9FxaD3S0wdNgvzY08f2vxMuPZCvf5lXFzE3oW)
    
      jpush_keys = %w(b789c8ed387ca31a1569c932:78ab7b77f32b35deccf4b847 9c75b77425cb280bc1c975fe:e2917386120a007763cb468e 8ea7cf97ac67608ba65c2db7:75c7d17c756279565ceb2b6f)

      apps = {1=>"bbrl_ios", 2=>"yun_ios", 3=>"yu_ios"}

      keys = %w(JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ HeMgqDP4SHKrZAn_dS_p1A:GROO_u1AQPi-XLRh9O7ixg 7vYTvD1ISfavgtt-MeQJwg:nWfmYnDhRcKNnNagbMs7tQ JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ HeMgqDP4SHKrZAn_dS_p1A:GROO_u1AQPi-XLRh9O7ixg 7vYTvD1ISfavgtt-MeQJwg:nWfmYnDhRcKNnNagbMs7tQ)
      cond = ["(user_id = #{user_id} or alias = '#{user.email}') and active=1"]
      #cond << "device_token = '#{device_token}'" if device_token
      apns = ApnDevice.find(:all, :conditions=>cond.join(' and '), :order=>"id desc", :limit=>30)
      return if apns.size == 0
      for apn in apns
        next if !apn.active
        next if !apn.user
        
        unread = apn.user.unread_atme_count.to_i + apn.user.unread_gifts_count.to_i + apn.user.unread_messages_count.to_i + apn.user.unread_comments_count.to_i + apn.user.unread_fans_count.to_i
        result = ""
        if apn.tp && apn.tp >= 4 && apn.device_token.size < 100
          if apn.device_token.length < 20            #极光推送
            if extras
              result = MamashaiTools::ToolUtil.fork_command %Q!curl --connect-timeout 10 -X POST -v https://api.jpush.cn/v3/push -H "Content-Type: application/json" -u "#{jpush_keys[apn.tp - 4]}" -d '{"platform":"android","audience":{"registration_id" : ["#{apn.device_token}"]},"notification":{"android": {"alert":"#{text}", "extras": #{extras.to_json}}}}'!
            else
              result = MamashaiTools::ToolUtil.fork_command %Q!curl --connect-timeout 10 -X POST -v https://api.jpush.cn/v3/push -H "Content-Type: application/json" -u "#{jpush_keys[apn.tp - 4]}" -d '{"platform":"android","audience":{"registration_id" : ["#{apn.device_token}"]},"notification":{"alert":"#{text}"}}'!
            end
          else
            #已废除
            #result = MamashaiTools::ToolUtil.fork_command %Q!curl --connect-timeout 10 -X POST -u "#{keys[apn.tp-1]}" -H "Content-Type: application/json" --data '{"android": {"alert": "#{text}"}, "apids": ["#{apn.device_token}"]}' https://go.urbanairship.com/api/push/!
          end
        else
          ApnDevice.send_apn(apn.tp, apn.device_token, text, unread, apn.silent, extras)
         end
      end
      message = ApnMessage.new
      message.user_id = user_id
      message.message = text
      message.tp = (apns.collect{|a| a.tp}).uniq.join(",")
      message.result = "save"
      message.save
    end

    def self.calc_distance(birthday, today=nil)
      today = Date.today if !today
      distance = 0
      if birthday <= today          #已出生
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
        distance = year*48 + month*4 + (date/7)
      else                    # 未出生
        days_diff = (today - birthday).to_i
        distance = -(-days_diff/7).abs
        if (days_diff%7).abs > 0
          distance -= 1
        end
      end
      return distance
    end
  end
end
