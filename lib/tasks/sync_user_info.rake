namespace :mamashai do
  desc "同步用户信息"
  task :sync_user_info  => [:environment] do
    cursor = 1000000000000
    infos = UserInfo.all(:conditions=>"id < #{cursor}", :limit=>1000, :order=>"id desc")
    while infos.size > 0
      for info in infos
        p info.id
        user = User.find_by_id(info.user_id)
        next if !user
        user.last_login_ip = info.ip
        user.last_login_at = info.last_login_at
        user.remark = info.mobile
        user.sid = info.sid
        user.save
        info.destroy
      end
      cursor = infos.last.id
      infos = UserInfo.all(:conditions=>"id < #{cursor}", :limit=>1000, :order=>"id desc")
    end
  end
end
