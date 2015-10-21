require 'open-uri'
require 'timeout'
namespace :mamashai do
  desc "更新关联的新浪微博"
  task :update_sina_weibo  => [:environment] do
    #先删掉不良信息
    #Post.delete_all("match(content_) against('+复制器' in boolean mode) ")
    #Post.delete_all("match(content_) against('+银行 +复制' in boolean mode) ")
    #Post.delete_all("match(content_) against('+银行 +破解' in boolean mode) ")
    #Post.delete_all("match(content_) against('+密码 +破解 +干扰' in boolean mode) ")
    #Post.delete_all("match(content_) against('+克隆 +银行' in boolean mode) ")
    #Post.delete_all("match(content_) against('+出售 +银行 +QQ' in boolean mode) ")
    
    for post in Post.find(:all, :conditions=>"match(content_) against('+复制器' in boolean mode) ")
      post.destroy
    end
    
    for post in Post.find(:all, :conditions=>"match(content_) against('+银行 +复制' in boolean mode) ")
      post.destroy
    end
    
    for post in Post.find(:all, :conditions=>"match(content_) against('+银行 +破解' in boolean mode) ")
      post.destroy
    end
    
    for post in Post.find(:all, :conditions=>"match(content_) against('+密码 +破解 +干扰' in boolean mode) ")
      post.destroy
    end
    
    for post in Post.find(:all, :conditions=>"match(content_) against('+克隆 +银行' in boolean mode) ")
      post.destroy
    end
    
    for post in Post.find(:all, :conditions=>"match(content_) against('+出售 +银行' in boolean mode) ")
      post.destroy
    end
    
    for post in Post.find(:all, :conditions=>"match(content_) against('+百度 +银行 +QQ' in boolean mode) ")
      post.destroy
    end
    
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    log = Logger.new('/home/update_weibo.log')
#    while true
    log << Time.new
    offset = 0
    direction = ['desc', ''][rand(2)]
    while true
      user_weibos = UserWeibo.find(:all, :group=>"user_id", :order=>"id #{direction}", :offset=>offset, :limit=>1000)
      offset += 1000
      for user_weibo in user_weibos 
         next if !user_weibo.to_mamashai
         next if !user_weibo.user
         next if user_weibo.user.tp == -2
         begin
         Timeout::timeout(5) do |time|
            log.info "user_weibo_id: #{user_weibo.id}, user_id: #{user_weibo.user.id}"
            begin
              if user_weibo.tp == 1
                oauth.authorize_from_access(user_weibo.access_token, user_weibo.access_secret)
              else
                oauth = Weibo::OAuth.new($lama_key, $lama_secret)
              end
            rescue Exception=>err
              log.error '------------fuck authorize---------------------'
              next
            end
            next if !user_weibo.user
            begin
              timeline = Weibo::Base.new(oauth).user_timeline({:user_id => user_weibo.access_id})
            rescue Exception=>err
              log.error err
              log.info "--------------fuck2--------------------"
              next
            end
            log.info "timelines : #{timeline.size}"
            for line in timeline
              next if line['retweeted_status'].present?   #转发，不抓取
              
#              good = false
#              for word in %w(宝宝 妈妈 孩子 爸爸  父母 育儿 教育 教养 养育 怀孕 孕期 孕吐  幼儿园 小学 上学 公主 王子 宝贝 可爱 乖 萌 辣妈 喂养 奶粉 课外班 强生 帮宝适 湿疹 痱子 儿童 少儿 爷爷 奶奶 姥姥 姥爷 动物园 巧虎 迪斯尼 英语 钢琴 画画 作品 家教 家长 辅导 营养 咳嗽 发烧)
#                if line['text'].index(word)
#                  good = true
#                  break;
#                end
#              end
#              next if !good
              post = Post.new
              post.user_id = user_weibo.user_id
              post.content = line['text']
              post.sina_weibo_id = line['id']
              post.tencent_weibo_id = -1
              post.created_at = line['created_at']
              post.forward_posts_count = line['reposts_count'] || 0
              post.from = '新浪微博自动同步'
              begin
                post.save
                log.info "#{Time.new.to_s(:db)} #{user_weibo.user.name} repost: #{line['reposts_count']} #{post.content} "
                #log << "add post #{post.id} \n"
              rescue Exception=>err
                log.info "已经同步过了"
                break
              end
              
              pic_uri = line['original_pic']
              if pic_uri
                next if pic_uri.index('&') || !pic_uri.index('.')     #没有图片
                begin
                    path = web_data(pic_uri)
                    log.info "有图:" + pic_uri
                rescue Exception => err
                    log.error err
                    log.info "------------------------fuck3------------------"
                    next
                end
                file = File.open(path)
                post.logo = file
                post.save
                file.close
                File.delete(path)
              end
              
            end
          end
        rescue Exception=>err
          log.error err
          log.info '---------------fuck--------------'
        end
      end
      
      break if user_weibos.size == 0
    end
    log << Time.new
  end
  
  def web_data(url)
    file_name = "tmp/#{url.split('/').last}"
    p "get #{url}"
    `wget -q -T 4 -O #{file_name} '#{url}'`
    
    return file_name
  end
end