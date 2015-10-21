namespace :mamashai do
  desc "add test users"
  task :add_test_users  => [:environment] do
    cities = City.find(:all)
    city_ids = []
    for city in cities
      city_ids << city.id
    end
    ages = Age.find(:all)
    age_ids = []
    for age in ages
      age_ids << age.id
    end
    email_types = ["@163.com", "@126.com","@gmail.com", "@sina.cn", "@sohu.com", "@yahoo.cn", "@hotmail.com", "@qq.com", "@vip.163.com", "@yahoo.com.cn"]
    email_number = 0
    city_number = 0
    age_number = 0
    content_number = 0
    100000.times.each do |user_number|
      user = User.new
      user.email                  = "mamashai_#{user_number}#{email_types[email_number]}"
      email_number += 1
      email_number = 0 if email_number == email_types.length - 1
      user.password               = "e10adc3949ba59abbe56e057f20f883e"
      user.logo                   = ""
      user.name                   = "mamashai_#{user_number}"
      user.domain                 = ""
      user.gender                 = "m"
      user.gender                 = "w" if user_number % 2 == 0
      user.birthyear              = 80
      user.birthyear              = 70 if user_number % 2 == 0
      user.birthday               = "2000-01-01"
      user.job_title              = "工程师"
      user.msn                    = user.email
      user.qq                     = "#{10000 + user_number}"
      user.mobile                 = "13521425654"
      user.age_ids                = ""
      user.tag_ids                = ""
      user.tp                     = 0 
      user.score                  = 0  
      user.skin                   = 0   
      user.user_kids_count        = 0   
      user.follow_users_count     = 0    
      user.fans_users_count       = 0  
      user.posts_count            = 0  
      user.unread_fans_count      = 0   
      user.unread_comments_count  = 0   
      user.unread_answers_count   = 0   
      user.unread_messages_count  = 0   
      user.unread_gifts_count     = 0   
      user.unread_atme_count      = 0  
      user.city_id                = city_ids[city_number]
      city_number += 1
      city_number = 0 if city_number == city_ids.length
      user.province_id            = City.find(city_ids[city_number]).province_id
      user.age_id                 = age_ids[age_number]
      age_number += 1
      age_number = 0 if age_number == age_ids.length
      user.mms_level              = 1 if user_number % 150 == 3
      user.mms_level              = 2 if user_number % 657 == 7
      user.mms_level              = 3 if user_number % 273 == 3
      user.mms_level              = 10 if user_number % 4835 == 3
      if user.save
        puts "user_id:#{user.id}"
        10.times.each do |post_number|
          post = Post.new
          post.user_id = user.id
          post.content = "#{user.id}--#{post_number}回复@幸福的小篮子:在幼儿园里我就不知道是因为什么了，老师恐怕也没有那么多的耐心去了解，因为一天之中会发生几次这种突发的哭闹。我理解她在幼儿园哭可能是因为她想做某件事，但老师让她去做的是另一件事，但她又不敢向老师表达她自已的想法，老师也猜不出她倒底是想干什么，于是她就觉得委屈就开始哭。当老师再问她的时候她也一句话不说，把老师也急得够呛。"
          post.save
          puts "post_id:#{post.id}"
        end
      else
        puts "$$$$$"  
      end
    end
  end
end