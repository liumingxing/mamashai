namespace :mamashai do
  desc "获得日活跃数据"
  task :get_tongji_day  => [:environment] do
    day = Date.today - 1
    tongji = TongjiDay.find_by_day(day.to_s)
    tongji = TongjiDay.new(:day=>day) if !tongji
    end_day = Date.today
    first = Post.find(:first, :conditions=>["created_at > ?", Date.today], :order=>"id")
    second = Post.find(:first, :conditions=>["created_at > ?", Date.today-1], :order=>"id")

    tongji.a1 = User.count(:conditions=>["created_at < ?", end_day])    #总注册用户数
    tongji.a2 = User.count(:conditions=>["last_login_at > ?", end_day-1])    #登录用户数
    tongji.a3 = User.count(:conditions=>["created_at > ? and created_at < ?", end_day-1, end_day])   #微博绑定
    tongji.a6 = Post.all(:select=>"id", :conditions=>['is_hide<>1 and id>? and id<?',second.id, first.id], :group=>"user_id").size  #记录用户数
    tongji.a7 = Post.count(:conditions=>['is_hide<>1 and id>? and id<?',second.id, first.id])                                   #记录数
    tongji.a8 = Post.count(:conditions=>['is_hide<>1 and id>? and id<? and logo is not null',second.id, first.id])              #图片
    tongji.a9 = Post.count(:conditions=>["is_hide<>1 and id>? and id<? and `from`='video'",second.id, first.id])                #视频
    tongji.a10 = Post.count(:conditions=>["is_hide<>1 and id>? and id<? and `from`='dianping'",second.id, first.id])            #亲子城市
    tongji.a11 = FollowUser.count(:conditions=>["follow_user_id <> 431 and created_at > ? and created_at < ?", Date.today-1, Date.today]) #关注数
    tongji.a12 = GiftGet.count(:all, :conditions=>["created_at > ? and created_at < ?", Date.today-1, Date.today])              #礼物数
    tongji.a13 = Comment.count(:all, :conditions=>["created_at > ? and created_at < ?", Date.today-1, Date.today])              #评论量
    tongji.a14 = ScoreEvent.sum("score", :conditions=>["created_at > ? and created_at < ? and score > 0", Date.today - 1, Date.today])
    tongji.a15 = ScoreEvent.sum("score", :conditions=>["created_at > ? and created_at < ? and score < 0", Date.today - 1, Date.today])
    tongji.a16 = AlbumBook.count(:conditions=>["created_at > ? and created_at < ?", Date.today-1, Date.today])
    tongji.a17 = AlbumPage.count(:conditions=>["logo is not null and created_at > ? and created_at < ?", Date.today-1, Date.today])
    tongji.a18 = Apicall.sum("count", :conditions=>["occur = ? ", Date.today-1])

    tongji.a19 = User.count(:conditions=>["created_at > ? and created_at < ? and last_post_id is not null", end_day-1, end_day])

    tongji.a21 = ApnDevice.count(:conditions=>["created_at > ? and created_at < ?", end_day-1, end_day])
    
    c = Apicall.first(:conditions=>["occur = ? and name = ?", day, 'videos.visit'])
    tongji.a20 = c.count if c
    tongji.save
  end
end