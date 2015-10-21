namespace :mamashai do
  desc "推送送宝宝日历宝典"
  task :send_bbrl_article  => [:environment] do
    keys = %w(JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ HeMgqDP4SHKrZAn_dS_p1A:GROO_u1AQPi-XLRh9O7ixg 7vYTvD1ISfavgtt-MeQJwg:nWfmYnDhRcKNnNagbMs7tQ JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ HeMgqDP4SHKrZAn_dS_p1A:GROO_u1AQPi-XLRh9O7ixg 7vYTvD1ISfavgtt-MeQJwg:nWfmYnDhRcKNnNagbMs7tQ)
    
    articles = Article.find(:all, :conditions=>"state='未发布' and article_category_id <> 51")
    for article in articles
      article.state = "已发布"
      article.created_at = Time.new
      article.save
    end
    article = Article.find(:first, :order=>"id desc", :conditions=>"state='已发布'")
    

    now = Time.new
    ApplicationIDs = %w(nJwnXAVGWQRlDU4nyihzPcrDkSR2XoUil3UfxZsk ghYhOyMFv2huU7UxMuo5mdoAS20VpIyyYBlUNjlc UnLOphymTe6HhVsX1H8qJriGeOfpbzWfEwb4pQhp)
    RESTKeys = %w(psYNG1xYcd0k8IExR4RTlnYd2McjqbCgcaTwwyNK wS69Bvdb5cXy4mrWjiJpuc9k5MWBuCavXJTpdEcT ORr9FxaD3S0wdNgvzY08f2vxMuPZCvf5lXFzE3oW)
    
    jpush_keys = %w(b789c8ed387ca31a1569c932:78ab7b77f32b35deccf4b847 9c75b77425cb280bc1c975fe:e2917386120a007763cb468e 8ea7cf97ac67608ba65c2db7:75c7d17c756279565ceb2b6f)

    keys.each_with_index{ |key, index|
        p index
        next if index == 0
        #break if [0, 3, 6].include?(now.wday)
        if index >= 3
          #result = MamashaiTools::ToolUtil.fork_command %Q!curl -X POST -v https://api.jpush.cn/v3/push -H "Content-Type: application/json" -u "#{jpush_keys[index-3]}" -d '{"platform":"android","audience":"all","notification":{"alert":"育儿宝典：#{article.title}"}}'!
          result = MamashaiTools::ToolUtil.fork_command %Q!curl -X POST -v https://api.jpush.cn/v3/push -H "Content-Type: application/json" -u "#{jpush_keys[index-3]}" -d '{"platform":"android","audience":"all","notification":{"android": {"alert":"育儿宝典：#{article.title}", "extras":{"t":"article", "id":#{article.id}}}}}'!
        else
          begin
            ApnDevice.broadcast_apn(index + 1, "育儿宝典：" + article.title, {"t"=>"article", "id"=>article.id})
          rescue Exception=>err
            p err
          end  
        end
        #result = MamashaiTools::ToolUtil.fork_command %Q!curl -X POST -u "#{keys[index]}" -H "Content-Type: application/json" --data '{"aps": {"alert": "育儿宝典：#{article.title}"}}' https://go.urbanairship.com/api/push/broadcast/!
        #result = MamashaiTools::ToolUtil.fork_command %Q!curl -X POST -H "X-Parse-Application-Id: #{ApplicationIDs[index]}" -H "X-Parse-REST-API-Key: #{RESTKeys[index]}" -H "Content-Type: application/json" -d '{"where":{"deviceType": "ios"},"data":{"alert": "育儿宝典：#{article.title}"}}' https://api.parse.com/1/push!
        
    }
  end
end
