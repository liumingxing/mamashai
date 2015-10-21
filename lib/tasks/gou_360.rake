require "net/http"
require 'nokogiri'
require 'uri'
require 'open-uri'

include ActiveSupport::JSON::Encoding

namespace :mamashai do
  desc "抓取京东商城数据"
  task :gou_360  => [:environment] do
    p "开始抓取京东商城数据 ..."
    
    all = Nokogiri::HTML(web_data('http://www.360buy.com/allSort.aspx'), nil, 'gbk')
    cate_links = all.css('div.w div.m')[5].css('div.mc dl dd a')
    progress = SpideProgress.get(5)
    if progress
      index = 0
      cate_links.each_with_index{|cate, i|
        index = i and break if cate['href'] == progress
      }
      0.upto(index-1) do cate_links.shift end
    end
    cate_links.each do |cate_link|
          puts cate_link.text
          
          SpideProgress.set(5, cate_link['href'])
          page = Nokogiri::HTML(web_data("http://www.360buy.com/" + cate_link['href']), nil, 'gb2312')
          while page
            threads = []
            page.css('div#plist ul li').each do |product|
               threads << Thread.new {
                  begin
                    url = product.css("div.p-name a")[0]['href']
                    full_html = web_data(url)
                    detail_page = Nokogiri::HTML(full_html, nil, 'gb2312')
                    cate = detail_page.css("div.crumb").text.strip.gsub("首页 > ", '')
                    name = detail_page.css("div#name h1").text
                    image = detail_page.css("div.jqzoom img")[0]['src']
                    url.scan(/\/(\d+)\.html/)
                    number = $1
                    price = parse_price(product.css("div.p-price img")[0]["src"])
                    
                    content = detail_page.css("div.content").inner_html.to_utf8.strip
                    
                    brand = standard = begin_time = ''
                    detail_page.css("ul#i-detail li").each do |attribute|
                      begin
                        brand = attribute.text.gsub('生产厂家：', '').strip.delete(' \t\n　') if attribute.text.index('生产厂家：')
                        standard = attribute.text.gsub('规格：', '').strip.delete(' \t\n　') if attribute.text.index('规格：')
                        begin_time = attribute.text.gsub('上架时间：', '').strip.delete(' \t\n　') if attribute.text.index('上架时间：')
                      rescue
                      end
                    end
                    
#                    puts url
#                    puts name
#                    puts content.to_s
#                    puts image
#                    puts number
#                    puts brand
#                    puts price
                       
                    res = Net::HTTP.post_form(URI.parse('http://www.mamashai.com/gou/add_gou'),
                      {'cate'=>cate, 'name'=>name, 'site_id'=>5, 
                       'content' => content, 
                       'logo' => image, 
                       'link'=>url, 'number' => number,
                       'standard' =>standard,
                       'brand' => brand,
                       'price'=>price,
                       'begin_time'=>begin_time
                       })
                    next if res.body == "0"
           
                    comment_page = Nokogiri::HTML(web_data("http://club.360buy.com/review/#{number}-1-1.html"), nil, 'gbk')
                    page_index = 1
                    while comment_page
                      comment_page.css("ul.PR_list").each do |comment|
                        user_name = comment.css("li.PR_list_l")[0]["name"]
                        created_at = comment.css("div.re_topic span.float_Right").text
                        content = comment.css("div.re_con dl").text.gsub("\r\n\t\t\t\t", " ").gsub("\r\n\t\t\t", "<br/>")
                        comment.css("div.re_topic img")[0]["src"].scan(/(\d+).jpg/)
                        rates = $1.to_i * 2
                        
#                        puts user_name
#                        puts rates
#                        puts created_at
#                        p content
                                                
                        Net::HTTP.post_form(URI.parse('http://www.mamashai.com/gou/add_comment'),
                        {'brand'=>brand, 'user_name'=>user_name, 
                         'content'=>content,
                         'kind' => 1, 'site_id'=>5, 'kind_id' => res.body,
                         'site_name' => '京东商城', 
                         'created_at' => created_at,
                         'rate' => rates
                        })
                      end
                      page_index += 1
                      break if page_index > 10
                      if comment_page.css("div.Pagination a").size > 0
                        comment_page = Nokogiri::HTML(web_data("http://comm.dangdang.com/review/reviewlist.php?pid=#{number}&page=#{page_index}"), nil, 'gbk')
                      else
                        comment_page = nil
                      end
                    end
                    
                    
                  rescue Exception=>err
                    p url
                    p err
                    p err.backtrace
                  end
                }    
            end
            for thread in threads
              thread.join
            end
            if page.css('a.next').size > 0
                page = Nokogiri::HTML(web_data(page.css('a.next')[0]['href']))  
            else
                page = nil
            end
            p '--------change page --------'
          end
    end
    
    p "抓取京东商城数据结束"
    SpideProgress.remove(5)
  end
  
  def web_data(url)
    file_name = "tmp/#{Time.new.to_i}#{rand(100000)}"
    `wget -q -T40 -O #{file_name} '#{url}'`
    #`curl -s -o #{file_name} '#{url}'`
    file = File.new(file_name, 'r')
    txt = file.read()
    file.close
    `rm -f #{file_name}`
    return txt
  end
  
  require 'RMagick'
  include Magick

  $map = {
  '0'=>%w(0 1 1 1 1 0 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 0 1 1 1 1 0),
  '1'=>%w(0 0 1 1 0 0 0 1 1 1 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 1 1 1 1 0),
  '2'=>%w(0 1 1 1 1 0 1 1 0 0 1 1 0 0 0 0 1 1 0 0 0 1 1 0 0 0 1 1 0 0 0 1 1 0 0 0 1 1 0 0 0 0 1 1 1 1 1 1),
  '3'=>%w(0 1 1 1 1 0 1 1 0 0 1 1 0 0 0 0 1 1 0 0 1 1 1 0 0 0 0 0 1 1 0 0 0 0 1 1 1 1 0 0 1 1 0 1 1 1 1 0),
  '4'=>%w(0 0 0 0 1 0 0 0 0 1 1 0 0 0 1 1 1 0 0 1 0 1 1 0 1 0 0 1 1 0 1 1 1 1 1 1 0 0 0 1 1 0 0 0 0 1 1 0),
  '5'=>%w(0 1 1 1 1 1 0 1 1 0 0 0 0 1 1 0 0 0 0 1 1 1 1 0 0 0 0 0 1 1 0 0 0 0 1 1 1 1 0 0 1 1 0 1 1 1 1 0),
  '6'=>%w(0 0 1 1 1 0 0 1 1 0 0 0 1 1 0 0 0 0 1 1 1 1 1 0 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 0 1 1 1 1 0),
  '7'=>%w(1 1 1 1 1 1 0 0 0 0 1 1 0 0 0 1 1 0 0 0 0 1 1 0 0 0 1 1 0 0 0 0 1 1 0 0 0 1 1 0 0 0 0 1 1 0 0 0),
  '8'=>%w(0 1 1 1 1 0 1 1 0 0 1 1 1 1 0 0 1 1 0 1 1 1 1 0 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 0 1 1 1 1 0),
  '9'=>%w(0 1 1 1 1 0 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 0 1 1 1 1 1 0 0 0 0 1 1 0 0 0 1 1 0 0 1 1 1 0 0),
  '.'=>%w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 1 1 0 0)
  }
  
  def parse_price(url)
    result = ''
    cat = ImageList.new(url)
    15.step(100, 2) {|i|
      begin
        arr = cat.get_pixels(i, 3, 6, 8).collect{|p| if (p.blue>>8) == 255 then 0 elsif (p.blue>>8)==206 then 3 else 1 end}
        for key in $map.keys.sort.reverse 
          m = $map[key]
          flag = true
          m.each_index{|index|
            if m[index].to_i == 1 && arr[index].to_i == 0 || m[index].to_i == 0 && arr[index].to_i == 1
              flag = false
              break
            end
          }
          
          if flag
            result <<  key
            break
          end
        end
      rescue
        break
      end
    }
    return result.to_f
  end
  
end
