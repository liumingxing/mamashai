namespace :mamashai do
  desc "reset apps"
  task :upload_post_logo  => [:environment] do
    cursor = 205463001
    offset = 0
    posts = Post.all(:order=>"id desc", :limit=>10000, :conditions=>"id > 204592579 and id < #{cursor}")
    while posts.size > 0
      for post in posts
        post.upload_to_aliyun
        p post.id
      end
      cursor = posts.last.id
      posts = Post.all(:order=>"id desc", :limit=>10000, :conditions=>"id > 204592579 and id < #{cursor}")
    end
  end
end