namespace :mamashai do
  desc "update user weibos.  per 10 min "
  task :update_weibos  => [:environment] do
    sys_job_log = SysJobLog.create(:sys_job_name=>'update_weibos')
    UserWeibo.all(:conditions=>["users.tp >= ?", 0], :include=>[:user]).each do |weibo|
        weibo.update_user_weibo_posts
    end
    sys_job_log.update_attributes(:finished_at=>Time.now)
  end
end