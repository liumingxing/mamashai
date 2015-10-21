namespace :mamashai do
  desc "update user blogs.  per 1 hour "
  task :update_blogs  => [:environment] do
    sys_job_log = SysJobLog.create(:sys_job_name=>'update_blogs')
    UserBlog.find(:all).each do |user_blog| 
      UserBlog.update_user_blog_posts(user_blog,user_blog.user)
    end
    sys_job_log.update_attributes(:finished_at=>Time.now)
  end
end