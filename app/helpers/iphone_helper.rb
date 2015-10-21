module IphoneHelper
  def phone_from_txt(post)
    return "来自#{post['subject.name']}" if post["subject"] && post["subject"]["name"]
    return "来自问答" if post["score"]
    return "来自团购" if post["tuan_id"]
    return "来自相册评论" if post["from"] == "picture"
    return "来自专栏" if post["from"] == "column"
    return "来自快乐淘" if post["from"] == 'tao'
    return "来自免费拿" if post["from"] == 'na'
    return "来自妈妈团" if post["from"] == 'tuan'
    return "来自妈妈晒下载" if post["from"] == 'download'
    return "来自辣妈日报" if post["from"] == "lama_web" || post["from"] == "lama_phone"
    return "来自iphone" if post["from"] == 'iphone'
    return "来自android客户端" if post["from"] == 'android'
    return "来自微博"
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
  
  def zoom_imaeg_tag(small_path, big_path)
    return '' if small_path.to_s.size == 0
    "<a href='/iphone/dialog?src=#{big_path}' data-rel='dialog' data-transition='flip'><img border='0' src='#{small_path}' ></a>"
  end
  
  def zoom_upload_pic(text)
    text.gsub(/<img.+\/([-\w&;]+)_thumb120.+?>/) {|match|
      match.scan(/src="(.+?)"/)
      small = $1
      return match if !$1 || !$1.index("_thumb120")
      big_path = $1.gsub("_thumb120", "_thumb400")
      "<a data-rel='dialog' data-transition='flip' href='/iphone/dialog?src=#{URI.escape(big_path)}'><img src='#{small}' /></a>"
    }
  end
  
  def iphone_post_content(content)
    content.gsub(/\(\:(.+?)\)/i,'<img src="/images/smiles/\\1.gif"/>').gsub(/#(.+?)#/){|g| "<span class='tag'>##{$1.to_s}#</span>" }
  end
  
  def iphone_post_content2(content)
    content.gsub(/\(\:(.+?)\)/i,'<img src="/images/smiles/\\1.gif"/>').gsub(/#(.+?)#/){|g| "<a href='/iphone/tag/#{URI.escape($1.to_s)}'>##{$1.to_s}#</a>" }
  end
end
