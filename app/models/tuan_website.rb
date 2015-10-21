require 'nokogiri'
require 'open-uri'

class TuanWebsite < ActiveRecord::Base
  has_many :tuans, :dependent => :delete_all
  has_many :tuan_temps, :dependent => :delete_all
  has_many :tuan_comments, :dependent => :delete_all
  serialize :catch_config,Hash
  
  CONFIGURES = %w{root|根节点  content|标题 url|链接地址 begin_time|开始时间 end_time|结束时间 origin_price|原价 current_price|现价 person_amount|购买人数}
  TUAN123 = "http://www.letyo.com/api/product.php?account=mamashai&key=1662c60ad6295cbb5ccf9f214a5115bd"
  def self.configures
    CONFIGURES
  end
  
#  def self.set_average_rate(website)
#    rates_count = website.rates_count + 1
#    value_1_sum = website.tuan_comments.all(:conditions => ['tuan_comments.value_1 is not NULL']).collect{|t| t}.sum{|comment| comment.value_1 * 2 }
#    value_2_sum = website.tuan_comments.all(:conditions => ['tuan_comments.value_2 is not NULL']).collect{|t| t}.sum{|comment| comment.value_2 * 2 }
#    value_3_sum = website.tuan_comments.all(:conditions => ['tuan_comments.value_3 is not NULL']).collect{|t| t}.sum{|comment| comment.value_3 * 2 }
#    website.update_attributes(:value_1 => (value_1_sum/rates_count*10).round/10.0, :value_2 => (value_2_sum/rates_count*10).round/10.0, :value_3 => (value_3_sum/rates_count*10).round/10.0, :average_rate => (((value_1_sum + value_2_sum + value_3_sum)/rates_count*10)/3).round/10.0) if value_1_sum and value_2_sum and value_3_sum and website.update_attribute("rates_count", rates_count)
#  end
#  
#  def self.delete_average_rate(website,comment) 
#    if website.rates_count <= 1
#      website.update_attributes(:average_rate=>0,:rates_count=>0, :value_1 => nil, :value_2 => nil, :value_3 => nil)
#    else
#      rates_count = website.rates_count - 1
#      value_1_sum = TuanComment.all(:conditions => ['tuan_comments.value_1 is not NULL and tuan_comments.id != ? and tuan_website_id = ?', comment.id, website.id]).collect{|t| t}.sum{|tuan_comment| tuan_comment.value_1 * 2 }
#      value_2_sum = TuanComment.all(:conditions => ['tuan_comments.value_2 is not NULL and tuan_comments.id != ? and tuan_website_id = ?', comment.id, website.id]).collect{|t| t}.sum{|tuan_comment| tuan_comment.value_2 * 2 }
#      value_3_sum = TuanComment.all(:conditions => ['tuan_comments.value_3 is not NULL and tuan_comments.id != ? and tuan_website_id = ?', comment.id, website.id]).collect{|t| t}.sum{|tuan_comment| tuan_comment.value_3 * 2 }
#      website.update_attributes(:value_1 => (value_1_sum/rates_count*10).round/10.0, :value_2 => (value_2_sum/rates_count*10).round/10.0, :value_3 => (value_3_sum/rates_count*10).round/10.0, :average_rate => (((value_1_sum + value_2_sum + value_3_sum)/rates_count*10)/3).round/10.0) if value_1_sum and value_2_sum and value_3_sum and website.update_attribute("rates_count", rates_count)
#    end
#  end

  def self.set_average_rate(website)
    rates_count = website.rates_count + 1
    rate_sum = website.tuan_comments.all(:conditions => ['tuan_website_id = ? and tuan_comments.rate is not NULL', website.id]).sum{|comment| comment.rate * 2 }
    website.update_attribute("average_rate",(rate_sum/rates_count*10).round/10.0) if rate_sum and website.update_attribute("rates_count", rates_count)
  end
  
  def self.delete_average_rate(website,comment) 
    if website.rates_count <= 1
      website.update_attributes(:average_rate=>0,:tuan_comments_count=>0)
    else
      rates_count = website.rates_count - 1
      rate_sum = website.tuan_comments.all(:conditions => ['tuan_website_id = ? and tuan_comments.rate is not NULL and id <> ?', website.id, comment.id]).sum{|comment| comment.rate * 2 }
      website.update_attribute("average_rate",(rate_sum/rates_count*10).round/10.0) if rate_sum and website.update_attribute("rates_count", rates_count)
    end
  end
  
  def self.set_average_hot_count(website)
    if website.tuans_count > 0 && Time.new.min == 10
      sum = website.tuans.collect{|t| t}.sum{|tuan| tuan.buyers_count}    #此操作从数10万条数据中取上百条数据，很费时间
      website.update_attributes(:average_hot_count=>(sum/website.tuans_count*10).round/10.0)
    end
  end
  
  def self.can_catch
    TuanWebsite.all(:select=>"catch_url",:conditions=>["catch_url is not ? and catch_config is not ?",nil,nil])
  end
  
  def can_catch
    self.catch_url and self.catch_config
  end
  
  def catch_from_xml
    filename = File.join(RAILS_ROOT,"tmp","tuans",self.id.to_s+".xml")
    content = `curl -o #{filename} #{self.catch_url}`
    logger.info content
  end
  
  def load_from_xml
    # filename = File.join(RAILS_ROOT,"tmp","tuans",self.id.to_s+".xml")
    tuan_temps = []
    begin
      xml =Nokogiri::XML(open(self.catch_url)) 
      configures = self.catch_config   
      xml.xpath("//#{configures[:root]}").each do |element|
        tid = element.xpath(configures[:tid]).text
        t = Tuan.find_by_tid_and_tuan_website_id(tid,self.id)
        t = TuanTemp.find_or_initialize_by_tid(tid) unless t
        configures.except('root').each do |key,value|
          t.try(key+"=",element.xpath(value).text) unless value.blank?
        end 
        if t.kind_of?(TuanTemp)
          self.tuan_temps << t
          tuan_temps << t
          logger.info "生成临时团购信息:"+t.content
        else
          logger.info("信息更新:"+t.content) if t.save
        end
      end 
    rescue => e
      logger.info "抓取团购API失败:"+e.inspect.to_s
    end
    tuan_temps
  end
  
  def load_tuan_from_xml(tuan) 
    tuan.tuan_website_id = self.id
    begin
      xml =Nokogiri::XML(open(self.catch_url)) 
      configures = self.catch_config   
      xml.xpath("//#{configures[:root]}").each do |element|  
        configures.except('root').each do |key,value|
          tuan.try(key+"=",element.xpath(value).text) unless value.blank?
        end  
        break
      end 
    rescue => e
      logger.info "抓取团购API失败:"+e.inspect.to_s
    end
    tuan 
  end
  
  def catch
    # catch_from_xml
    load_from_xml
  end
  
  def self.catch_from_tuan123
    unless File.directory? File.join(RAILS_ROOT,"tmp","tuans")
      Dir.mkdir("#{RAILS_ROOT}/tmp/tuans")
    end
    success,fail = 0,0
    xml =Nokogiri::XML(open(TUAN123))
    xml.xpath("//city").each do |city|
      city.xpath("./product").each do |product|
        ActiveRecord::Base.transaction do
          begin
            t = Tuan.find_or_initialize_by_url(product.xpath("./productUrl").text)
            t.address = city.xpath("./cityName").text
            t.begin_time = product.xpath("./productStartTs").text
            t.end_time = product.xpath("./productEndTs").text
            t.content = product.xpath("./productName").text
            t.origin_price = product.xpath("./productValue").text.try(:to_f)
            t.current_price = product.xpath("./productPrice").text.try(:to_f)
            t.person_amount = product.xpath("./productBought").text.try(:to_i)
            t.logo = t.catch_image(product.xpath("./productImg").text) if t.logo.blank?
            
            if t.new_record?
              t.tp = -1
              t.sale_count = 0
              tuan_category_temp = TuanCategoryTemp.find_or_create_by_name(product.xpath("./productCategory").text)
              tuan_category = tuan_category_temp.tuan_category
              if tuan_category
                t.tuan_category = tuan_category
              else
                t.tuan_category_temp = tuan_category_temp
              end              
              tuan_website = TuanWebsite.find_or_create_by_name(product.xpath("./siteName").text)
              t.tuan_website = tuan_website
              t.level = tuan_website.tp
            end
            if t.save
              success+=1
            end
          rescue => e
            fail +=1
            logger.error "抓取团购信息失败:"+e.inspect.to_s
          end
        end
      end
    end 
    logger.info "抓取团123结束,成功："+success.to_s+"，失败："+fail.to_s
  end
  
  def open_xml_tmp_file
    filename = File.join(RAILS_ROOT,"tmp","tuans",self.id.to_s+".xml")
    return filename if File.exists?(filename)
    return nil
  end
  
  def self.grade_labels
    [[1,'宝贝与描述相符'],[2,'卖家的服务态度'],[3,'卖家发货的速度']]
  end
  
end
