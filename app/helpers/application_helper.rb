require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/filters'
require 'action_view/helpers/tag_helper'

module ApplicationHelper
  def adv_link(code, length=1)
    adv_pos = Advertisement.find_by_code(code)
    logos = AdvertisementLogo.find(:all, :conditions=>"advertisement_id = #{adv_pos.id} and status='online'", :limit=>adv_pos.num, :order=>"id")
    res = ""
    for logo in logos
      res += "<a href='#{logo.url.to_s.size > 0 ? logo.url : "javascript:void(0)"}' #{"target='_blank'" if logo.url.to_s.size > 0}><img src='#{logo.logo}'/></a>"
    end
    res.html_safe
  end
  
  def include_action_js
    js_action = @js_action || params[:action]
    js_controller = @js_controller || params[:controller]
    js_path = File.join(::Rails.root.to_s,"public","javascripts","controllers",js_controller,"#{js_action}.js")
    lib_js_name = "controllers/#{js_controller}/#{js_action}"
    #    if js_controller == "baby_books"
    return javascript_include_tag(lib_js_name) if File.exists?(js_path)
    #    else
    #      return zip_js_by_name_and_path(lib_js_name,js_path)
    #    end
  end
  
  def include_lib_js
    js_controller = @js_controller || params[:controller]
    tags = []
    tags << javascript_include_tag("controllers/mms_jquery_lib.min")
    tags << stylesheet_link_tag("/javascripts/js_ui_stylesheets/smoothness/jquery-ui-1.8.1.custom.css")
    
    js_path = File.join(::Rails.root.to_s,"public","javascripts","controllers",js_controller,"#{js_controller}_lib.js")
    lib_js_name = "controllers/#{js_controller}/#{js_controller}_lib"
    js_code = zip_js_by_name_and_path(lib_js_name,js_path)
    tags << js_code if js_code
    
    js_path = File.join(::Rails.root.to_s,"public","javascripts","controllers","mms_lib.js")
    lib_js_name = "controllers/mms_lib"
    js_code = zip_js_by_name_and_path(lib_js_name,js_path)
    tags << js_code if js_code
    
    return tags.join("\n") 
  end
  
  def date_en(time)
    time.strftime("%Y-%m-%d") if time
  end
  
  def date_cn(time)
    time.strftime("%Y#{APP_CONFIG['time_label_y']}%m#{APP_CONFIG['time_label_m']}%d#{APP_CONFIG['time_label_d']}") if time
  end
  
  def date_cn_week(time)
    if time
      str = time.strftime("%Y#{APP_CONFIG['time_label_y']}%m#{APP_CONFIG['time_label_m']}%d#{APP_CONFIG['time_label_d']}") 
      return "#{str} #{APP_CONFIG['week_days_cn'].split('|')[time.wday-1]}"
    else
      return ""
    end
  end
  
  def time_en(time)
    time.strftime("%H:%M:%S") if time
  end
  
  def event_time(event)
    start_at = event.start_at
    end_at = event.end_at
    if start_at.to_date == end_at.to_date
      start_at.strftime("%Y#{APP_CONFIG['time_label_y']}%m#{APP_CONFIG['time_label_m']}%d#{APP_CONFIG['time_label_d']}%H:%M") + end_at.strftime("-%H:%M")
    else
      start_at.strftime("%Y#{APP_CONFIG['time_label_y']}%m#{APP_CONFIG['time_label_m']}%d#{APP_CONFIG['time_label_d']}%H:%M") + end_at.strftime("-%m#{APP_CONFIG['time_label_m']}%d#{APP_CONFIG['time_label_d']}%H:%M")
    end
  end
  
  def date_time(time)
    time.strftime("%Y-%m-%d %H:%M") if time
  end  
  
  def refer_time(from_time, to_time = Time.now, include_seconds = false, include_hour = true)
    return 'no time' unless from_time
    #from_time = from_time.to_time if from_time.respond_to?(:to_time)
    #to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    
      if include_hour 
        date_time from_time
      else
        from_time.to_date
      end
  end
  
  def diff_day(time1,time2)
    if time2.to_date.month < time1.to_date.month
     (time2.to_date.month+12-time1.to_date.month)*30+(time2.to_date.day-time1.to_date.day)
    else
     (time2.to_date.month-time1.to_date.month)*30+(time2.to_date.day-time1.to_date.day)
    end
  end
  
  def user_birthday_str(user) 
    if user and user.birthyear
      return "#{user.birthyear}#{APP_CONFIG['birthyear']}" + user.birthday.strftime(" %m#{APP_CONFIG['time_label_m']}%d#{APP_CONFIG['time_label_d']}")
    end
  end
  
  def link_user(user)
    if user.tp==2
      "<a href='#{user_url(user)}' class='vipname' >#{user.name_str}</a>".html_safe
    elsif user.tp==3
      "<a href='#{user_url(user)}'>#{user.name_str}</a> <a href='javascript:void(0)' style='margin-left: -2px;'><img style='vertical-align: top; margin: 0px; border: 0px;' src='/images/icon_v.jpg' style='border:0px;'/></a>".html_safe
    else
      "<a href='#{user_url(user)}'>#{user.name_str}</a>".html_safe
    end 
  end

  def link_user_to_space(user)
    if user.tp==2
      "<a href='/column/space/#{user.id}' class='vipname' >#{truncate(user.name_str,7,"...")}</a>".html_safe
    elsif user.tp==3
      "<a href='/column/space/#{user.id}'>#{truncate(user.name_str, :length=>7)}</a> <a href='javascript:void(0)' title='#{user.remark}' ><img src='/images/icons/attest.gif' style='border:0px;'/></a>".html_safe
    else
      "<a href='/column/space/#{user.id}'>#{truncate(user.name_str, :length=>7)}</a>".html_safe
    end
  end

  def mamashai_pmt(tp)
    if tp =='score'
      return '<div id="mm_score_pmt" class="painting_pic"><div class="del"><a href="javascript:void(0)" onclick="Element.hide(\'mm_score_pmt\')"><img src="/images/painting/del_06.gif"></a></div><a href="/scores/rewards" class="painting_one"></a></div>'.html_safe
    end
    if tp =='user_tags'
      return '<div id="mm_tags_pmt" class="painting"><div class="del"><a href="javascript:void(0)" onclick="Element.hide(\'mm_tags_pmt\')"><img src="/images/painting/del_06.gif"></a></div><div class="no_money"><a href="/settings/tags"><img src="/images/painting/button_12.gif"></a></div></div>'.html_safe
    end
    if tp =='reward_tags'
      tag = Tag.find(Tag.reward_tag_ids[2])
      return '<div id="mm_reward_pmt" class="painting painting01"><div class="del"><a href="javascript:void(0)" onclick="Element.hide(\'mm_reward_pmt\')"><img src="/images/painting/del_06.gif"></a></div><div class="no_money"><a href="/home/tag/'+tag.name+'" ><img src="/images/painting/button_14.gif"></a></div></div>'.html_safe
    end
    if tp =='user_logo'
      return '<div id="mm_logo_pmt" class="painting painting03"><div class="del"><a href="javascript:void(0)" onclick="Element.hide(\'mm_logo_pmt\')"><img src="/images/painting/del_06.gif"></a></div><div class="no_money"><a href="/settings/logo"><img src="/images/painting/button_08.gif"></a></div></div>'.html_safe
    end
    if tp =='user_mobile'
      return '<div id="mm_mobile_pmt" class="painting painting04"><div class="del"><a href="javascript:void(0)" onclick="Element.hide(\'mm_mobile_pmt\')"><img src="/images/painting/del_06.gif"></a></div><div class="no_money"><a href="/mobile"><img src="/images/painting/button_06.gif"></a></div></div>'.html_safe
    end
    if tp =='over_50_follows'
      return '<div id="mm_follows_pmt" class="painting painting05"><div class="del"><a href="javascript:void(0)" onclick="Element.hide(\'mm_follows_pmt\')"><img src="/images/painting/del_06.gif"></a></div><div class="no_money"><a href="/friends"><img src="/images/painting/button_03.gif"></a></div></div>'.html_safe
    end
  end
  
  def mamashai_rand_pmt(user)
    pmt_tps = ['user_tags','reward_tags','user_logo','user_mobile','over_50_follows']
    user_profile = user.user_profile
    score_actions = user_profile.score_actions.split('|') if user_profile and user_profile.score_actions
    if score_actions
      score_actions.each do |score_action|
        pmt_tps.delete(score_action)
      end
    end
    #  rand_index = rand(3)
    #  if rand_index == 1
    #    return mamashai_pmt(pmt_tps[rand(pmt_tps.length)])
    #  else
    return mamashai_pmt('book')
    #  end
  end
  
  def select_config_items(config_name)
    i=0
    APP_CONFIG[config_name].split('|').collect{|name|
      i+=1
      [name,i]
    }
  end
  
  def detail_age_for_birthday(birthday, today=Date.today)
    str = ''
    motn_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if today.year % 4 == 0
      motn_days[1] = 29;
    end
    if birthday
      _birthday = birthday
      if today < birthday 
        pregnant_day = birthday - 280 
        birthday = pregnant_day
      end
      months = today.month - birthday.month
      years = today.year - birthday.year
      days = today.day - birthday.day 
      if today >= birthday 
        if months < 0
          years -=1
          months = 12 + months
        end
        if days < 0
          months -=1
          days = motn_days[birthday.month-1] + days
        end
        if months < 0
          years -=1
          months = 12 + months
        end
        if pregnant_day
          today_date = Date.new(today.year, today.month, today.mday)
          diff_days = 280 - (_birthday - today_date).to_i
          str = "孕"
          str += (diff_days/7).to_s + "周" if diff_days/7 > 0
          str += (diff_days%7).to_s + "天" if diff_days%7 > 0 
          str = "出生啦" if diff_days == 280
          #str = "#{APP_CONFIG['have_baby']}#{months}个#{APP_CONFIG['time_label_m']}#{days}#{APP_CONFIG['day']}"
        else
          if years == 0 && months == 0 && days == 0
            return "出生啦"
          end
          str = ""
          str += "#{years}#{APP_CONFIG['age']}" if years > 0
          str += "#{months}个#{APP_CONFIG['time_label_m']}" if months > 0
          str += "#{days}#{APP_CONFIG['day']}" if days > 0
          #str = "#{years}#{APP_CONFIG['age']}#{months}个#{APP_CONFIG['time_label_m']}#{days}#{APP_CONFIG['day']}"
        end
      end
    end
    str
  end 
  
  def html_content(content)
    content.gsub(/<iframe(.+?)<\/iframe>/i,'').gsub(/<script(.+?)<\/script>/i,'')
  end
  
  def pure_text(content)
    h(strip_tags(content)).gsub(/\r\n/i,'')
  end
  
  def post_rate_tag(post,wapper=true)
    str = "<span class='allstar allstar#{post.rate.to_i}'>#{post.rate}</span><span class='all_c'>(#{post.rates_count}#{APP_CONFIG['posts_rate_count_label']})</span>"
    str = "<div id='post_rate_view_#{post.id}'>#{str}</div>" if wapper
    str
  end
  
  def ifnull_str(obj,params) 
    str = ''
    str = APP_CONFIG[params[:pmt]] if params[:pmt]
    unless (obj.blank? or obj.send(params[:method]).blank?)
      str = obj.send(params[:method])
      str = simple_format(h(str)) if params[:format]
    end
    str
  end
  
  def post_tags_str(post)
    str = ""
    str = "<a href='/home/find_posts?search_post[age_id]=#{post.age_id}&search_post[category_id]=-1'>[#{post.age.name}]</a> " if post.age
    tag = post.tag
    if tag
      if post.subject_id.present?
        str += "<a href='/g/#{post.subject_id}'>[#{tag.name}]</a> "
      else
        str += "<a href='/home/tag/#{tag.name}'>[#{tag.name}]</a> "
      end
    end
    return str.html_safe
  end
  
  def cut_html(content,len=250)
    truncate(strip_tags(content).gsub(/[\t\n ]/, '').gsub(/&\w+;/, ''),{:length=>len})
  end
  
  def post_content(content)
    auto_link(h(content.gsub(/&.+;/, '')).gsub(/@(\w{1,20})$|@(\w{1,20})([\s\,\:\：。，\，\！\!\(\)\（\）\=\-\[\]"\'\>\<\?\*\/])|@(\w{1,20})@/i,'<a href="/friends/find_user/\\1\\2">@\\1\\2</a>\\3').gsub(/#(.+?)#/){|g| "<a href='/topic/#{$1.to_s}'>##{$1.to_s}#</a>" },:all,:target => "_blank").gsub(/\(\:(.+?)\)/i,'<img src="/images/smiles/\\1.gif"/>').gsub(/©/,'@').gsub(/\[(.+?)\]/){|g|  File.exist?("#{::Rails.root.to_s}/public/images/face/#{$1.to_s}.png") ? "<img style='width: 20px; height: 20px;' src='/images/face/#{$1.to_s}.png' />" : "#{$1.to_s}"}.html_safe
  
    #h(content.gsub(/&.+;/, '')).gsub('：', ':').gsub(/@(\w{1,20})$|@(\w{1,20})([\s\,\:\：。，\，\！\!\(\)\（\）\=\-\[\]"\'\>\<\?\*\/])|@(\w{1,20})@/i,'<a href="/friends/find_user/\\1\\2">@\\1\\2</a>\\3').gsub(/#(.+?)#/){|g| "<a href='/topic/#{$1.to_s}'>##{$1.to_s}#</a>" }.gsub(/\(\:(.+?)\)/i,'<img src="/images/smiles/\\1.gif"/>').gsub(/©/,'@').gsub(/\[(.+?)\]/){|g|  File.exist?("#{RAILS_ROOT}/public/images/face/#{$1.to_s}.png") ? "<img style='width: 20px; height: 20px;' src='/images/face/#{$1.to_s}.png' />" : "#{$1.to_s}"}
  end

  def post_http_content(content)
    auto_link(h(content.gsub(/&.+;/, '')).gsub(/@(\w{1,20})$|@(\w{1,20})([\s\,\:\：。，\，\！\!\(\)\（\）\=\-\[\]"\'\>\<\?\*\/])|@(\w{1,20})@/i,'<a href="/friends/find_user/\\1\\2">@\\1\\2</a>\\3').gsub(/#(.+?)#/){|g| "<a href='/topic/#{$1.to_s}'>##{$1.to_s}#</a>" },:all,:target => "_blank").gsub(/\(\:(.+?)\)/i,'<img src="/images/smiles/\\1.gif"/>').gsub(/©/,'@').gsub(/\[(.+?)\]/){|g|  File.exist?("#{::Rails.root.to_s}/public/images/face/#{$1.to_s}.png") ? "<img style='width: 20px; height: 20px;' src='/images/face/#{$1.to_s}.png' />" : "#{$1.to_s}"}.html_safe
  end
  
  def long_post_content(content)
    #   mms_auto_link(simple_format(h(content).gsub(/@(\w{1,20})$|@(\w{1,20})([\s\,\:\：。\，\！\!\(\)\（\）\=\-\[\]"\'\>\<\?\*\/])|@(\w{1,20})@/i,'<a href="/friends/find_user/\\1\\2">@\\1\\2</a>\\3')),:all,:target => "_blank").gsub(/\(\:(.+?)\)/i,'<img src="/images/smiles/\\1.gif"/>').sub(/\[(.+?)\]/,'').gsub(/©/,'@')
    html_content(content).html_safe
  end

  def face_content(content)
    text = content.gsub(/\[(.+?)\]/){|g|  File.exist?("#{::Rails.root.to_s}/public/images/face/#{$1.to_s}.png") ? "<img style='width: 20px; height: 20px;' src='/images/face/#{$1.to_s}.png' />" : "#{$1.to_s}"}
    text.html_safe
  end
  
  def post_blog_url(post)
    "<a href='#{post.blog_url.url}' target='_blank'>http://mamashai.com/blog/#{post.id}</a>"
  end
  
  def post_video_url(post)
    "<a href='#{post.video_url.url}' target='_blank'>http://mamashai.com/video/#{post.id}</a>"
  end 
  
  def comment_or_answer(post)
    return '回答' if post.score.present?
    return '评论'
  end
  
  def post_from_txt(post)
    from = "来自网页"
    from = "来自<a href='#{user_url(post.forward_user)}' title='#{post.forward_user.name}' >#{post.forward_user.name}</a>" if post.forward_user
    from = "来自<a href='/settings/blog'>同步博客</a>" if post.blog_url 
#    from = "来自<a href='/mobile'>WAP手机版</a>" if post.mobile_tp == 2
#    from = "来自手机客户端" if post.mobile_tp == 3
    from = "来自<a href='/sub/#{post.subject_id}'>#{post.subject.name}</a>" if post.subject_id && post.subject
    from = "来自<a href='/ask'>问答</a>" if post.score.present?
#    from = "来自<a href='/tuan/show/#{post.tuan_id}'>团购</a>" if post.tuan_id
    from = "来自<a href='/user/#{post.picture.album.user.encrypt_user_id}'>#{post.picture.album.user.name}</a>的<a href='/albums/show/#{post.picture.album.id}##{post.picture.logo.web}'>相册评论</a>" if post.from == "picture" && post.picture && post.picture.album
    from = "来自<a href='/column/space/#{post.user.id}'>#{post.user.name}</a>的专栏<a href='/column/space/#{post.user.id}?column_id=#{post.column_chapter.column_book.id}&tp=chapter'>#{post.column_chapter.column_book.name}</a>" if post.from == "column" && post.column_chapter && post.column_chapter.column_book && post.user
    from = "来自<a href='/tao'>快乐淘</a>" if post.from == 'tao'
    from = "来自<a href='/na'>免费拿</a>" if post.from == 'na'
    from = "来自<a href='/tuan'>妈妈团</a>" if post.from == 'tuan'
    from = "来自<a href='/mms_tools/show/#{post.from_id}'>妈妈晒下载</a>" if post.from == 'download'
    from = "来自<a href='http://lama.mamashai.com'>辣妈日报</a>" if post.from == "lama_web" || post.from == "lama_phone"
    from = "来自<a href='http://apps.weibo.com/lamadiary' href='_blank'>辣妈日报新浪微博站内版</a>" if post.from == 'lama_sina'
    from = "来自<a href='http://lamaqq.mamashai.com' href='_blank'>辣妈日报腾讯微博版</a>" if post.from == 'lama_qq'
    from = "来自<a href='/lmrb' target='_blank'>辣妈日报</a>iphone版" if post.from == 'lama_iphone'
    from = "来自iphone" if post.from == 'iphone'
    from = "来自ipad" if post.from == 'ipad'
    from = "来自android" if post.from == 'android'
    from = "来自<a href='/vmodel/'>小麻豆</a>" if post.from == 'lama_vmodel'
    from = "来自<a href='/weitongxing/'>微童星</a>" if post.from == 'lama_vkid'
    from = "来自<a href='/princess/'>小公主大赛</a>" if post.from == 'lama_princess'
    from = "来自<a href='/sunuo/' target='_blank'>苏诺童品</a>" if post.from == 'lama_sntp'
    from = "来自<a href='tonghua' target='_blank'>秋天的童话</a>" if post.from == 'lama_tonghua'
    from = "来自<a href='/bbrl' target='_blank'>宝宝日历</a>".html_safe if %w(calendar shanguang fayu yingyang zaojiao caiyi biaoqing bbyulu shijian wenzi jiance album_book taotaole video).include?(post.from)
    from = "来自<a href='/tao/show/#{post.from_id}'>我淘</a>" if post.from == "wotao"
    from = "来自<a href='/articles/article/#{post.from_id}'>宝典</a>" if post.from == "article"
    
    from.html_safe
  end
  
  def logo_tag2(obj, pic_params={})
    class_name = 'img_border'
    style = ''
    id = ''
    time_str = ''
    id = pic_params[:id] if pic_params[:id]
    other = ''
    other = pic_params[:other] if pic_params[:other]
    class_name = pic_params[:class] if pic_params[:class]
    style = pic_params[:style] if pic_params[:style]
    blank_logo_name = obj.class.to_s.downcase + '_logo'
    if pic_params[:version]
      blank_logo_name = obj.class.to_s.downcase + '_logo_' + pic_params[:version] 
      version_str = "_#{pic_params[:version]}"
    end
    if pic_params[:time]
      time_str = "?#{Time.now.strftime('%H%M%S')}"
    end
    if pic_params[:title]
      title = pic_params[:title]
    elsif obj.kind_of?(User)
      title = obj.name
    end
    
    if obj and obj.logo
      if obj.class == User
        img = "<img class='#{class_name}' #{'id='+id if id.size > 0} #{'style="' +  style + '"' if style.size > 0} #{other} src='http://mamashai-videos.oss-cn-qingdao.aliyuncs.com#{obj.send("logo#{version_str}").url + time_str}' />"
      else
        img = "<img class='#{class_name}' #{'id='+id if id.size > 0} #{'style="' +  style + '"' if style.size > 0} #{other} src='#{obj.send("logo#{version_str}").url + time_str}' />"
      end
    else 
      img = '<img class="'+class_name+'" id="'+id+'" style="'+style+'" '+other+' src="/images/logos/'+blank_logo_name+'.gif"/>'
    end
  end
  
  def logo_tag(obj,pic_params={})
    class_name = 'img_border'
    style = ''
    id = ''
    time_str = ''
    id = pic_params[:id] if pic_params[:id]
    other = ''
    other = pic_params[:other] if pic_params[:other]
    class_name = pic_params[:class] if pic_params[:class]
    style = pic_params[:style] if pic_params[:style]
    blank_logo_name = obj.class.to_s.downcase + '_logo'
    if pic_params[:version]
      blank_logo_name = obj.class.to_s.downcase + '_logo_' + pic_params[:version] 
      version_str = "_#{pic_params[:version]}"
    end
    if pic_params[:time]
      time_str = "?#{Time.now.strftime('%H%M%S')}"
    end
    if pic_params[:title]
      title = pic_params[:title]
    elsif obj.kind_of?(User)
      title = obj.name
    end
    
    
    if obj.class == User
        img = "<img class='#{class_name}' #{'id='+id if id.size > 0} #{'style="' +  style + '"' if style.size > 0} #{other} src='http://mamashai-videos.oss-cn-qingdao.aliyuncs.com#{obj.send("logo#{version_str}").url + time_str}' />"
    else
        img = "<img class='#{class_name}' #{'id='+id if id.size > 0} #{'style="' +  style + '"' if style.size > 0} #{other} src='#{obj.send("logo#{version_str}").url + time_str}' />"
    end
    
    str = "<a href=\"#{pic_params[:url].blank? ? '#' : pic_params[:url]}\" #{'target=_blank' if pic_params[:blank]}  #{'title="'+title if title}"+'"'+other+" onclick=\"#{pic_params[:onclick]}\" >#{img}</a>"
    str.html_safe
    #{}"<a>hello</a>".html_safe
  end 
  
  def user_url(user)
    url = ""
    url = "/user/#{user.encrypt_user_id}" if user
    "/u/#{user.domain}" if user && user.domain
    return url
  end
  
  def http_user_url(user)
    url =  "#{WEB_ROOT}/user/#{user.encrypt_user_id}" 
    url =  "#{WEB_ROOT}/u/#{user.domain}" if user.domain
    url
  end
  
  def post_url(post)
    "/post/#{post.id}" 
  end
  
  def subject_url(subject)
    "/g/#{subject.id}" 
  end
  
  def baby_book_url(baby_book)
    "/book/#{baby_book.id}"
  end
  
  
  
  def mms_auto_link(text, *args, &block)#link = :all, href_options = {}, &block)
    return '' if text.blank?
    
    options = args.size == 2 ? {} : args.extract_options! # this is necessary because the old auto_link API has a Hash as its last parameter
    unless args.empty?
      options[:link] = args[0] || :all
      options[:html] = args[1] || {}
    end
    options.reverse_merge!(:link => :all, :html => {})
    case options[:link].to_sym
      when :all                         then auto_link_email_addresses(mms_auto_link_urls(text, options[:html], &block), options[:html], &block)
      when :email_addresses             then auto_link_email_addresses(text, options[:html], &block)
      when :urls                        then mms_auto_link_urls(text, options[:html], &block)
    end
  end
  
  
  
  MMS_AUTO_LINK_RE = %r{
            ( https?:// | www\.| [0-9a-zA-Z\-]+\.)
            (\w+[\/\.])*
            [a-zA-Z0-9\.\/\\\_\?\-:=;&%#]+
          }x unless const_defined?(:MMS_AUTO_LINK_RE)
  #MMS_AUTO_LINK_RE = /(https+:\/\/)?([A-Za-z0-9\-]+\.)*[A-Za-z0-9\-]+[\/=\?%\-&_~`@[\]\':+!]*([^\"\"])*$/ unless const_defined?(:AUTO_LINK_RE)       
  
  MMS_BRACKETS = { ']' => '[', ')' => '(', '}' => '{' }
  
  # Turns all urls into clickable links.  If a block is given, each url
  # is yielded and the result is used as the link text.
  def mms_auto_link_urls(text, html_options = {})
    
    link_attributes = html_options.stringify_keys
    
    text.gsub(MMS_AUTO_LINK_RE) do
      href = $&     
      punctuation = ''
      left, right = $`, $'
      if /[@]/ =~ left or /[@]/ =~ right
        return text
      end
      # detect already linked URLs and URLs in the middle of a tag
      if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
        # do not change string; URL is alreay linked
        href     
      else
        # don't include trailing punctuation character as part of the URL
        if href.sub!(/[^\w\/-]$/, '') and punctuation = $& and opening = MMS_BRACKETS[punctuation]
          if href.scan(opening).size > href.scan(punctuation).size
            href << punctuation
            punctuation = ''
          end
        end
        
        link_text = block_given?? yield(href) : href
        href = 'http://' + href unless href.index('http') == 0
        
        content_tag(:a, h(link_text), link_attributes.merge('href' => href)) + punctuation
      end
    end
  end
  
  def zip_js(filename)
    min_file = get_min_js_file(filename)
    #    logger.info "js_name:"+"-"*20+min_file
    if !File.exists?(min_file) or File.new(filename).mtime - File.new(min_file).mtime > 0
      result= `/usr/local/bin/juicer merge -i #{filename} --force` 
      logger.info "juicer-js:"+result+"-"*20
    end
  end
  
  def zip_css(filename)
    css_name = File.join(RAILS_ROOT,"public",filename)
    min_css_name = get_min_css_file(css_name)
    #    logger.info "css_name:"+"-"*20+css_name
    if !File.exists?(min_css_name) or File.new(css_name).mtime - File.new(min_css_name).mtime > 0
        result = `/usr/local/bin/juicer merge -i #{css_name} --force`
        logger.info "juicer-css:"+result+"-"*20
    end
    get_min_css_file(filename)
  end
  
  def get_min_js_file(filename)
    filename.sub(/\.js/,".min.js") 
  end
  
  def get_min_css_file(filename)
    filename.match(/\.css/) ? filename.sub(/\.css/,".min.css") : filename+=".min.css" 
  end
  
#  def stylesheet_link_tag(*sources)
#    sources.collect! {|s| zip_css(stylesheet_path(s).sub(/\?\d*/,'')) } if RAILS_ENV == 'production'
#    super(*sources)
#  end
  
  def zip_js_by_name_and_path(name,path)
    if File.exists?(path)
      #      (zip_js(path); name += ".min") if RAILS_ENV == 'production'
      return javascript_include_tag(name)
    end
    return "" 
  end
  
  def state_machine_tag(instance, origin_url)
    @instance = instance
    @origin_url = origin_url
    render :partial => '/ajax/state_index'
  end
  
  # ======== 修改广告 =========
  
  def update_advertisement(position)
    advertisement = Advertisement.find_by_position(position)    
    str = (advertisement.content unless advertisement.blank?) || ""
  end
  
  def smile_div(close_js, &block)
    content = capture(&block)
    concat %!
      <div class="smiles">
            <div class="del_button">
                <a href="javascript:void(0)" onclick="#{close_js}"><img src="/images/layer/del_06.gif"></a>
            </div>
            <div class="smiles_top">
                <div class="clear">
                </div>
            </div>
            <div class="smiles_content">
                <div>#{content}</div>
                <div class="clear">
                </div>
            </div>
            <div class="smiles_bottom">
                <div class="clear">
                </div>
            </div>
        </div>
    !, block.binding
  end
  
  #评论矩形
  def comment_div(&block)
    content = capture(&block)
    concat %!
    <div class="comments01">
    <div class="comments01_bg1">
    </div>
    <div class="comments01_bg2">
      #{content}
    </div>
    <div class="comments01_bg3"></div>
    </div>
    <div class="clear"></div>
    !, block.binding
  end
  
  #可关闭的box框
  def box_div(&block)
    content = capture(&block)
    concat %!
      <div class="box">
        #{content}
      </div>
    !, block.binding
  end
  
  def mms_recommand(t, id)
    return "" if (!@user || !@user.is_admin) && !@mms_user
    recommand = Recommand.find(:first, :conditions=>"t='#{t}' and t_id = #{id}")
    if recommand    #已经是推荐了
      "<span id='recommand_#{id}'><a title='取消推荐' href='javascript:void(0);' onclick=\"$('#recommand_#{id}').load('/ajax/add_recommand?t=#{t}&id=#{id}') \"><img src='/images/icons/award_star_gold_3.png' alt='取消推荐' title='取消推荐' /></a></span> |".html_safe
    else            #还不是推荐
      "<span id='recommand_#{id}'><a title='精彩推荐' href='javascript:void(0);' onclick=\"$('#recommand_#{id}').load('/ajax/add_recommand?t=#{t}&id=#{id}') \"><img src='/images/icons/award_star_add.png' border='0'/></a></span> |".html_safe
    end
  end
  
  def kid_desc(kid)
    return "" if !kid
    "#{kid.name}#{detail_age_for_birthday(kid.birthday)}"
  end
  
  def kid_age(user, time=Date.today)
    kids = UserKid.find(:all, :conditions=>"user_id = #{user.id}", :order=>"birthday desc")
    str = kids.collect{|kid| "#{kid.name}#{detail_age_for_birthday(kid.birthday, time)}"}.join(' ') if kids.size > 0
  end
  
  def post_clap(post)
    if @user
      if @user.id == post.user_id 
        result = "<a href='javascript:void(0)' onclick='show_url_box(\"/ajax/clap_users/#{post.id}\", \"她们点了喜欢 :）\")'><img src='/images/icon_10.jpg' /></a>"
      else
        if post.from == "wotao"
          #result = %q!<a href="#" onclick="$.ajax({complete:function(request){$('#claps_count_#{post.id}').html(request.responseText);}, dataType:'script', type:'post', url:'/ajax/clap/#{post.from_id}?tp=post'}); return false;"><img src="/images/icon_10.jpg"></a>!
          result = link_to image_tag("/images/icon_10.jpg"), {:controller=>"ajax", :action=>"clap", :tp=>'wotao', :id=>post.from_id}, {:remote=>true, :updater=>"claps_count_#{post.id}"}
        else
          #result = %q!<a href="#" onclick="$.ajax({complete:function(request){$('#claps_count_#{post.id}').html(request.responseText);}, dataType:'script', type:'post', url:'/ajax/clap/#{post.id}?tp=post'}); return false;"><img src="/images/icon_10.jpg"></a>!
          result = link_to image_tag("/images/icon_10.jpg"), {:controller=>"ajax", :action=>"clap", :tp=>'post', :id=>post}, {:remote=>true, :updater=>"claps_count_#{post.id}"}
        end
      end
    else
      result = content_tag(:a, "<img src='/images/icon_10.jpg'>".html_safe, :href=>"/account/signup/#{post.user_id}")
    end
    if post.from == "wotao"
      c = Clap.count(:conditions=>"tp='wotao' and id = #{post.from_id}")
      if c > 0
        result += content_tag(:span, " &nbsp;(#{c})".html_safe,  :id=>"claps_count_#{post.id}", :class=>"number")
      else
        result += content_tag(:span, '',  :id=>"claps_count_#{post.id}", :class=>"number")
      end
    else
      if post.claps_count > 0
        result += content_tag(:span, " &nbsp;(#{post.claps_count})".html_safe,  :id=>"claps_count_#{post.id}", :class=>"number")
      else
        result += content_tag(:span, '',  :id=>"claps_count_#{post.id}", :class=>"number")
      end
    end

    result.html_safe
    #"<a>aa</a>".html_safe
  end
  
  def user_skin(user)
    if user && user.my_skin
      "<style>body {background:url(#{user.my_skin}) repeat #fff;}</style>"
    end
  end
  
  def placeholder(str)
    "placeholder=\"#{str}\""
  end
  
  def round_rect(&block)
    content = capture(&block)
    concat %!
      <div class="rounded-box">
    <div class="top-left-corner"><div class="top-left-inside">&#8226;</div></div>
    <div class="bottom-left-corner"><div class="bottom-left-inside">&#8226;</div></div>
    <div class="top-right-corner"><div class="top-right-inside">&#8226;</div></div>
    <div class="bottom-right-corner"><div class="bottom-right-inside">&#8226;</div></div>
    <div class="box-contents">
        #{content}
    </div>
</div>    
    !, block.binding
  end

  def tiny_mce_js
    %Q(
    <script src="/javascripts/tiny_mce/tiny_mce.js?1340120505" type="text/javascript"></script>
    <script type="text/javascript">
    //<![CDATA[
    tinyMCE.init({
    browsers : "msie,gecko",
    entity_encoding : "utf-8",
    document_base_url : '/',
    language : 'zh-cn',
    mode : 'textareas',
    paste_auto_cleanup_on_paste : true,
    plugins : "contextmenu,inlinepopups,paste,emotions,fullscreen,advimage,table,media,searchreplace,insertdatetime",
    relative_urls : false,
    remove_script_host : false,
    theme : 'advanced',
    theme_advanced_buttons1 : "formatselect,fontselect,fontsizeselect,bold,italic,underline,separator,justifyleft,justifycenter,justifyright,indent,outdent,separator,bullist,numlist,forecolor,backcolor",
    theme_advanced_buttons2 : "undo,redo,cut,copy,paste,pasteword,|,search,replace,|,table,image,media,emotions,charmap,separator,link,unlink,removeformat,|,fullscreen,code",
    theme_advanced_buttons3 : "",
    theme_advanced_fonts : '宋体=宋体;黑体=黑体;仿宋=仿宋;楷体=楷体;隶书=隶书;幼圆=幼圆;Arial=arial,helvetica,sans-serif;Comic Sans MS=comic sans ms,sans-serif;Courier New=courier new,courier;Tahoma=tahoma,arial,helvetica,sans-serif;Times New Roman=times new roman,times;Verdana=verdana,geneva;Webdings=webdings;Wingdings=wingdings,zapf dingbats',
    theme_advanced_resize_horizontal : false,
    theme_advanced_resizing : true,
    theme_advanced_toolbar_align : 'left',
    theme_advanced_toolbar_location : 'top'
    });
    //]]>
    </script>
    ).html_safe
  end
end
