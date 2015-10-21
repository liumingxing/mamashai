namespace :mamashai do
  desc "update hot tags. per 1 day "
  task :update_hot_tags  => [:environment] do
    ActiveRecord::Base.transaction do
      HotTag.delete_all(["days=?",1])
      Post.find(:all,:limit=>50,:select=>'tag_id,count(tag_id) as tp',:include=>[:tag],
          :conditions=>['created_at > ? and tag_id is not null and tag_id <> 38',Date.today-1],
          :group=>'tag_id',:order=>'count(tag_id) desc').collect{|post| 
        next if !post.tag
        HotTag.create(:name=>post.tag.name,:posts_count=>post.tp,:days=>1,:tag_id=>post.tag_id)
      }
    end
  end

  task :update_post_month => [:environment] do
    offset = 60000
    posts = Post.all(:limit=>2000, :offset=>offset, :include=>"user")
    while posts.size > 0
      for post in posts
        post.get_kid_month
        post.save
        p post.id
      end
      offset += 2000
      posts = Post.all(:limit=>2000, :offset=>offset)
    end
  end
end