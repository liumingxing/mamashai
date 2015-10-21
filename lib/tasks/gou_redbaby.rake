require "net/http"
require 'nokogiri'
require 'uri'
require 'open-uri'

namespace :mamashai do
  desc "抓取红孩子数据"
  task :gou_redbaby  => [:environment] do
    p "开始抓取红孩子数据 ..."
    
    all = Nokogiri::HTML(web_data('http://www.redbaby.com.cn/category/'))
    cate_links = []
    all.css('div.allbrandRightMain').each do |div|
      next if div.css('div.allbrandRightMainTitle a').text == "图书城"
      div.css("div.allbrandContent").each do |t|
        cate_links += t.css("div.allbrandContentBoxLeft a")
        cate_links += t.css("span a") if t.css("div.allbrandContentBoxLeft a").size == 0
      end
    end
    
    progress = SpideProgress.get(1)
    if progress
      index = 0
      cate_links.each_with_index{|cate, i|
        index = i and break if cate['href'] == progress
      }
      0.upto(index-1) do cate_links.shift end 
    end
    cate_links.each do |cate_link|
          puts cate_link.text
          SpideProgress.set(1, cate_link['href']) 
          
          page = Nokogiri::HTML(web_data("http://www.redbaby.com.cn#{cate_link['href']}"))
          while page
            #pool = ThreadPool.new(32) 
            threads = []
            page.css('ul li.globalProductWhite').each do |product| 
            #    pool.process {
               threads << Thread.new {
                  begin
                    url = product.css('div.globalProductName a')[0]['href'] 
                    detail_page = Nokogiri::HTML(web_data(url))
                    name = detail_page.css("div.productInfo div.productName h1").text.strip.gsub(/\s+/, ' ')
                    image = detail_page.css("div.jqzoom img")[0]['src']
                    number = detail_page.css("span.font_gary")[0].text.gsub("商品编码：", '')
                    brand = detail_page.css("div.productInfoBrand div.body a").text
                    price_text = web_data("http://www.redbaby.com.cn/catalog/product/getPriceInfo?id=#{number}")
                    price = price_text.scan(/'price'>([\d\.]+)<\/span>/)[0][0]
                    if detail_page.css("div#commonBasicInfo ul li").size == 3
                      standard = ''
                      begin_time = detail_page.css("div#commonBasicInfo ul li")[2].text.gsub("上架时间：", '')
                    else
                      standard = detail_page.css("div#commonBasicInfo ul li")[2].text.gsub("规格：", '')
                      begin_time = detail_page.css("div#commonBasicInfo ul li")[3].text.gsub("上架时间：", '')
                    end
                    rate = rate_count = 0
                    rate = detail_page.css('div.productInfoScores span.scoreText').text.to_f*2
                    detail_page.css('div.productInfoScores a.font_blue').text.scan(/\d+/)
                    rate_count = $&
                   
                    res = Net::HTTP.post_form(URI.parse('http://www.mamashai.com/gou/add_gou'),
                      {'cate'=>cate_link.text, 'name'=>name, 'site_id'=>1, 
                       'content' => detail_page.css("div#productDescription").to_html, 
                       'logo' => image, 
                       'link'=>url, 'number' => number,
                       'standard' =>standard,
                       'brand' => brand,
                       'price'=>price,
                       'begin_time'=>begin_time,
                       'rate' => rate,
                       'rate_count' => rate_count
                       })
                    
                    next if res.body == "0"
                    
                    comments_page = Nokogiri::HTML(web_data(product.css("div.globalProductlistExtra a")[0]['href']))
                    comments_page.css("div.productCommentsTabBody").each do |c|
                      Net::HTTP.post_form(URI.parse('http://www.mamashai.com/gou/add_comment'),
                        {'brand'=>brand, 'user_name'=>c.css("ul li.commenter div.productCommentsName").text,
                         'created_at' => c.css("ul li.comments div.productCommentsTime").text.strip,
                         'content'=>c.css("ul li.comments div.productCommentsInfo").text,
                         'kind' => 1, 'site_id'=>1, 'kind_id' => res.body,
                         'site_name' => '红孩子商城', 
                           'rate' => (c.css('div.productCommentsTitle div.star')[0]['class'].scan(/\d+/)[0].to_i)*2/10 ###
                         })
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
            if page.css('a.right').size == 0
              page = nil
            else
              page = Nokogiri::HTML(web_data(page.css('a.right')[0]['href']))  
            end
          end
    end
    
    p "spide redbaby product finished"
    SpideProgress.remove(1)
  end
  
  def web_data(url)
    return open(url).read
    
    file_name = "tmp/#{Time.new.to_i}#{rand(100000)}"
    `wget -q -T40 -O #{file_name} '#{url}'`
    #`curl -s -o #{file_name} #{url}`
    file = File.new(file_name, 'r')
    txt = file.read()
    file.close
    `rm -f #{file_name}`
    return txt
  end
end
