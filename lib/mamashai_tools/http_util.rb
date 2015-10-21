require "iconv"

require 'uri'
require 'net/http'

require 'rubygems'
require 'simple-rss'


module MamashaiTools
  class HttpUtil
    def initialize
  end
  
   def self.get_blog_tps
      ['weibo', 'sina','sohu','163','baidu','babytree','hexun','blogbus']
    end
    
    def self.get_common_rss_url(blog_tp,blog_name) 
      time_now = Time.now.strftime("%Y%m%d%H%M")
      return "http://blog.sina.com.cn/rss/#{blog_name}.xml?#{time_now}" if blog_tp == 'sina'
      return "http://#{blog_name}.blog.sohu.com/rss?#{time_now}" if blog_tp == 'sohu'
      return "http://#{blog_name}.blog.163.com/rss/?#{time_now}" if blog_tp == '163'
      return "http://hi.baidu.com/#{blog_name}/rss?#{time_now}" if blog_tp == 'baidu'
      return "http://www.babytree.com/content/rss_feed.php?ver=2&uid=#{blog_name}" if blog_tp == 'babytree' 
      return "http://#{blog_name}.blog.hexun.com/rss2.aspx" if blog_tp == 'hexun'
      return "http://#{blog_name}.blogbus.com/index.rdf" if blog_tp == 'blogbus'
    end
    
    def self.get_common_emails(name)
      emails = [ "gmail.com",  "163.com", "qq.com", "126.com","sina.com","sohu.com","hotmail.com","yahoo.com" ]
      name_str = ''
      name_str = name unless name.blank?
      strs = name_str.split('@')
      name_str = strs[0]
      if strs.length>1
        return emails.collect{|email| "#{name_str}@#{email}" if email.index(strs[1])}.compact!
      else
        return emails.collect{|email| "#{name_str}@#{email}" }
      end
    end
    
    def self.get_blog_items(rss_url)
      xml_content = MamashaiTools::HttpUtil.get_http_content(rss_url) 
      encoding_index = xml_content.index('encoding="GBK"')
      if encoding_index and encoding_index > 0 and encoding_index < 50
        xml_content = Iconv.iconv("UTF-8//IGNORE","GB2312//IGNORE",xml_content)
      end
      begin
        result = SimpleRSS.parse(xml_content)
        return result.items
      rescue
        return nil
      end
    end
    
    def self.get_http_content(data_url)
      # http.open_timeout = http.read_timeout = 5
      # case res   when Net::HTTPSuccess, Net::HTTPRedirection  else res.error! end
      begin
        url = URI.parse(data_url)
        Net::HTTP.start(url.host, url.port) do |http|
          response = http.get(data_url,'User-Agent' =>'Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.6) Gecko/20091201 Firefox/3.5.6') 
          return response.body   
        end
      rescue
        return '404'
      end
    end  
    
    def self.send_fetion_invite(mobile)
      url = 'http://api.tui3.com/caesar/cmds.xml'
      account = 'mamashai,xyz'
      channel = 'fetion-ctrl'
      MamashaiTools::HttpUtil.rest_http_post(url,{'cmd[sender]'=>account,'cmd[channel]'=>channel,'cmd[to_ids]'=>mobile,'cmd[desc]'=>APP_CONFIG['mamashai'],'cmd[content]'=>'invite'})
    end
    
    def self.send_fetion_message(mobile,content)
      url = 'http://api.tui3.com/caesar/cmds.xml'
      account = 'mamashai,xyz'
      channel = 'fetion'
      MamashaiTools::HttpUtil.rest_http_post(url,{'cmd[sender]'=>account,'cmd[channel]'=>channel,'cmd[to_ids]'=>mobile,'cmd[content]'=>content})
    end
    
    def self.rest_http_post(url,params)
      begin
        res = Net::HTTP.post_form(URI.parse(url),params)
        return res.body
      rescue
        return '404'
      end
    end
    
  end
end
