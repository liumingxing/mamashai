require "net/http"
require 'nokogiri'
require 'uri'
require 'open-uri'

include ActiveSupport::JSON::Encoding

namespace :mamashai do
  desc "抓取当当网数据"
  task :gou_dangdang  => [:environment] do
    p "开始抓取当当网数据 ..."
    
    all = Nokogiri::HTML(web_data('http://category.dangdang.com/?ref=www-0-C#ref=www-0-C'), nil, 'gbk')
    cate_links = all.css('div.categories_mainBody div.mother div.mother_details ul li a')
    progress = SpideProgress.get(4)
    if progress
      index = 0
      cate_links.each_with_index{|cate, i|
        index = i and break if cate['href'] == progress
      }
      0.upto(index-1) do cate_links.shift end
    end
    cate_links.each do |cate_link|
          next if cate_link['class'] == "hot"
          puts cate_link.text
          
          SpideProgress.set(4, cate_link['href'])
          
          page = Nokogiri::HTML(web_data(cate_link['href']), nil, 'gbk')
          while page
            threads = []
            page.css('ul.mode_goods li div.name a').each do |product|
               threads << Thread.new {
                  begin
                    url = product['href']
                    full_html = web_data(url)
                    detail_page = Nokogiri::HTML(full_html, nil, 'gbk')
                    name = detail_page.css("div.h1_title h1").text
                    image = detail_page.css("div.show div.pic a img")[0]['src']
                    url.scan(/product_id=(\d+)/)
                    number = $1
                    price = detail_page.css("span#salePriceTag").text.delete('￥')
                    
                    if detail_page.css("div.right_content").size > 0
                      content = detail_page.css("div.right_content").inner_html
                      brand = standard = begin_time = ''
                      detail_page.css("div.mall_goods_foursort_style").each do |attribute|
                        brand = attribute.text.gsub('品牌：', '').strip.split(' ')[0].delete(' ') if attribute.text.index('品牌：')
                        standard = attribute.text.gsub('规格：', '').strip.delete(' \t\n　') if attribute.text.index('规格：')
                        begin_time = attribute.text.gsub('上架时间：', '').strip.delete(' ') if attribute.text.index('上架时间：')
                      end
                    else
                      content_html = web_data("http://product.dangdang.com/callback.php?type=detail&product_id=#{number}&page_type=mall")
                      content_html.scan(/var data = \{(.+?)\};/)
		                  content_page = Nokogiri::HTML(ActiveSupport::JSON.decode($1)["content"].to_utf8, nil, 'utf-8')
		                  
                      content = content_page.css("div.right_content").to_html  if content_page.css("div.right_content").size > 0
                      brand = standard = begin_time = ''
                      content_page.css("div.mall_goods_foursort_style_frame").each do |attribute|
                        brand = attribute.text.gsub('品牌：', '').strip.split(' ')[0].delete(' ') if attribute.text.index('品牌：')
                        standard = attribute.text.gsub('规格：', '').strip.delete(' \t\n　') if attribute.text.index('规格：')
                        begin_time = attribute.text.gsub('上架时间：', '').strip.delete(' ') if attribute.text.index('上架时间：')
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
                      {'cate'=>cate_link.text, 'name'=>name, 'site_id'=>4, 
                       'content' => content, 
                       'logo' => image, 
                       'link'=>url, 'number' => number,
                       'standard' =>standard,
                       'brand' => brand,
                       'price'=>price,
                       'begin_time'=>begin_time
                       })
                    next if res.body == "0"
           
                    comment_page = Nokogiri::HTML(web_data("http://comm.dangdang.com/review/reviewlist.php?pid=#{number}"), nil, 'gbk')
                    page_index = 1
                    while comment_page
                      comment_page.css("div.preview_content_bg").each do |comment|
                        user_name = comment.css("div.buyer p a").text
                        created_at = comment.css("span.mode_time").text
                        content = comment.css("div.buyer_comm div.center_topbg h3 a").text + "\n" + comment.css("div.pd_comm_con").text  + comment.css("div.center_border p").text
                        rates = 0
                        comment.css("span.span_star img").each do |img|
                          rates += 2 if img['src'].index('star_red.gif')
                        end
#                        puts user_name
#                        puts rates
#                        puts created_at
#                        puts content
                        
                        
                        Net::HTTP.post_form(URI.parse('http://www.mamashai.com/gou/add_comment'),
                        {'brand'=>brand, 'user_name'=>user_name, 
                         'content'=>content,
                         'kind' => 1, 'site_id'=>4, 'kind_id' => res.body,
                         'site_name' => '当当网', 
                         'created_at' => created_at,
                         'rate' => rates
                        })
                      end
                      page_index += 1
                      if comment_page.css("span.next a").size > 0
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
            if page.css('a.pagebtn[title="下一页"]').size > 0
                page = Nokogiri::HTML(web_data(page.css('a.pagebtn[title="下一页"]')[0]['href']))  
            else
                page = nil
            end
            p '--------change page --------'
          end
    end
    
    p "抓取当当网数据结束"
    SpideProgress.remove(4)
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
  
end
