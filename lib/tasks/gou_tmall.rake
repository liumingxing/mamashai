require "net/http"
require 'nokogiri'
require 'uri'
require 'open-uri'

namespace :mamashai do
  desc "抓取淘宝商城数据"
  task :gou_tmall  => [:environment] do
    p "开始抓取淘宝商城数据 ..."
    
    all = Nokogiri::HTML(web_data('http://www.tmall.com/go/rgn/tmall/hd-cat-asyn_v2.php'), nil, 'gbk')
    cate_links = all.css('div.J_SubViewItem')[8].css('.J_HotMenuItem dd a')
    progress = SpideProgress.get(2)
    if progress
      index = 0
      cate_links.each_with_index{|cate, i|
        index = i and break if cate['href'] == progress
      }
      0.upto(index-1) do cate_links.shift end
    end
    cate_links.each do |cate_link|
          puts cate_link.text
          SpideProgress.set(2, cate_link['href'])
          
          page = Nokogiri::HTML(web_data(cate_link['href']), nil, 'gbk')
          page_index = 0
          while page
            page_index += 1
            break if page_index > 40      #最多只抓取40页
            threads = []
            page.css('ul.product-list li.product h3 a').each do |product|
               threads << Thread.new {
                  begin
                    url = product['href']
                    full_html = web_data(url)
                    detail_page = Nokogiri::HTML(full_html, nil, 'gbk')
                    if detail_page.css("div#detail div h3 a").size > 0
                      name = detail_page.css("div#detail div h3 a").text.strip
                    else
                      name = detail_page.css("div#detail div h3").text.strip
                    end
                    image = detail_page.css("img#J_ImgBooth")[0]['src']
                    if url.scan(/id=(\d+)&/).size == 0
                      url.scan(/spu-(\d+)-/)
                    end
                    number = $1
                    price = detail_page.css("#J_StrPrice").text
                    brand = standard = begin_time = ''
                    detail_page.css("ul.attributes-list li").each do |attribute|
                      brand = attribute.text.gsub('品牌:', '').strip.split(' ')[0].delete(' ') if attribute.text.index('品牌:')
                      standard = attribute.text.gsub('规格:', '').strip.delete(' \t\n　') if attribute.text.index('规格:')
                      begin_time = attribute.text.gsub('上架时间:', '').strip.delete(' ') if attribute.text.index('上架时间:')
                    end
                    
                    full_html.scan(/"apiItemDesc":"(\S+)"/)
                    if $1
                      content = web_data($1).gsub("var desc='", '').chop.to_utf8.gsub("\\\n", "\n")
                    end
                    
#                    rate = rate_count = 0
#                    full_html.scan(/"apiMallReviews":"(\S+)"/)
#                    if $1
#                      content = web_data($1).to_utf8.scan(/title="(.+)"/)
#                      if $1
#                        rate = $1.to_f*2
#                        t = $1[$1.index('共')..$1.length] 
#                        t.scan(/(\d+)/)
#                        rate_count = $1
#                      end
#                    end
#                    full_html.scan(/"apiItemDesc":"(\S+)"/)
#                    if $1
#                      content = web_data($1).gsub("var desc='", '').chop.to_utf8.gsub("\\\n", "\n")
#                    end


#                    puts cate_link.text
#                    puts name
#                    p image
#                    p url
#                    p number
#                    puts standard
#                    puts brand
#                    p price
#                    p begin_time
                    
                    res = Net::HTTP.post_form(URI.parse('http://www.mamashai.com/gou/add_gou'),
                      {'cate'=>cate_link.text, 'name'=>name, 'site_id'=>3, 
                       'content' => content, 
                       'logo' => image, 
                       'link'=>url, 'number' => number,
                       'standard' =>standard,
                       'brand' => brand,
                       'price'=>price,
                       'begin_time'=>begin_time
                       })
                    next if res.body == "0"
                    
#                    path = File.join(RAILS_ROOT,"public","upload","gou",res.body)
#                    `wget -q -nc -P #{path} #{image}`
                    
                    full_html.scan(/"valReviewsApi":"(\S+)"/)
                    rates = []
                    if $1
                      rate_content = web_data($1).to_utf8
                      rate_content = rate_content.scan(/"rateList":\[([\S\W]+)\]/)
                      begin
                        rates = $1.split('},{')
                      rescue
                        p 'error in split'
                        p $1
                        p url
                        puts rate_content
                      end
                      for rate in rates
                        rate.scan(/"displayUserNick":"(.*?)"/)
                        user_name = $1
                        rate.scan(/"rateContent":"(.*?)"/)
                        content = $1
                        rate.scan(/"rateDate":"(.*?)"/)
                        created_at = $1.gsub('.', '-')
                        
                        Net::HTTP.post_form(URI.parse('http://www.mamashai.com/gou/add_comment'),
                        {'brand'=>brand, 'user_name'=>user_name, 
                         'content'=>content,
                         'kind' => 1, 'site_id'=>2, 'kind_id' => res.body,
                         'site_name' => '淘宝商城', 
                         'created_at' => created_at
                        })
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
            if page.css('a.next-page').size == 0
              page = nil
            else
              page = Nokogiri::HTML(web_data(page.css('a.next-page')[0]['href']))  
            end
          end
    end
    
    p "抓取淘宝数据结束"
    SpideProgress.remove(2)
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
  
  task :gou_picture  => [:environment] do
    for gou in Gou.find(:all, :conditions=>"id > 4000")
      path = File.join(RAILS_ROOT,"public","upload","gou_new", gou.id.to_s, gou['logo'])
      p path
      begin
        file = File.open(path, 'r')
        gou.logo = file
        gou.disable_ferret
        gou.save
        file.close
      rescue
      end
    end
  end
end