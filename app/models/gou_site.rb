require 'fileutils'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
class GouSite < ActiveRecord::Base
  upload_column :logo, :versions => {:thumb97=>"97x39"}
  
  has_many :gou_gou_sites, :dependent => :destroy
  has_many :gous, :through => :gou_gou_sites, :dependent => :destroy
  has_many :book_malls

  validates_presence_of(:name, :message => "商品网站名称不能为空")
  validates_presence_of(:url, :message => "商品网站ＵＲＬ地址不能为空")
  
  
  named_scope :publish, :conditions => ['gou_sites.state = ?', 'publish']
  
  state_machine :initial => :unpublish do
    state :unpublish
    state :publish
    
    event :publish do
      transition :unpublish => :publish
    end
    
    event :unpublish do
      transition :publish => :unpublish
    end
    
  end
  
  def self.catch_gous(url)
    begin
      doc = Nokogiri::XML(open(url))
      return if doc.blank?
      doc.remove_namespaces!
      products = doc.xpath("//ProductInfo")
      products.each do |product|
        brand = get_brand(product)
        next if brand.blank?
        third_category_name = product.at_xpath("./ProductThirdCategoryName").try(:text).try(:to_s)
        category = GouCategory.first(:conditions => ['gou_categories.brand_item LIKE ?', "%#{third_category_name}%"]) if third_category_name.present?
        second_category_name = product.at_xpath("./ProductSecondCategoryName").try(:text).try(:to_s)
        category = GouCategory.first(:conditions => ['gou_categories.brand_item LIKE ?', "%#{second_category_name}%"]) if third_category_name.blank? and second_category_name.present?
        get_product(product, category, brand)
      end
    rescue Exception=>e
      puts "抓取网站错误： #{e.message}"
    end
  end
    
  def self.get_brand(product)
    begin
      brand_name = product.at_xpath("./ProductBrand").try(:text).try(:to_s)
      return nil if brand_name.blank?
      brand = GouBrand.first(:conditions => ['name = ?', brand_name])
      brand.update_attributes(:name => brand_name) if brand.present?
      brand = GouBrand.create(:name => brand_name) if brand.blank?
      return brand
    rescue Exception=>e
      puts "抓取商品品牌错误： #{e.message}"
    end
  end
  
  def self.get_product(product, category, brand)
    begin
      site_name = product.at_xpath("./Name").try(:text).try(:to_s)
      name = product.at_xpath("./ProductName").try(:text).try(:to_s)
      url = product.at_xpath("./ProductUrl").try(:text).try(:to_s)
      content = product.at_xpath("./ProductIntro").try(:text).try(:to_s)
      price = product.at_xpath("./ProductSellPrice").try(:text).try(:to_f)
      standard = product.at_xpath("./ProductStandard").try(:text).try(:to_s)
      image_url = product.at_xpath("./ProductImages/ProductImageUrl").try(:text).try(:to_s)
      gou = Gou.first(:conditions => ['link = ?', url])
      gou.update_attributes(:name => name, :price => price, :content => content, :standard => standard, :link => url, :gou_category_id => category.id, :site_name =>  site_name, :gou_brand_id => brand.id, :state => 'publish', :logo => (File.open(image_url) if File.exist?(image_url)) || nil) if gou.present?
      gou = Gou.create(:name => name, :price => price, :content => content, :standard => standard, :link => url, :gou_category_id => category.id, :site_name =>  site_name, :gou_brand_id => brand.id, :state => 'publish', :logo => (File.open(image_url) if File.exist?(image_url)) || nil) if gou.blank?
      return gou
    rescue Exception=>e
      puts "抓取商品错误： #{e.message}"
    end
  end
    
  def self.generate_html(site_id, catch_time)
    FileUtils.mkdir_p(File.join(RAILS_ROOT,"tmp","gous")) unless File.directory?(File.join(RAILS_ROOT,"tmp","gous"))
    file_path = File.join(File.join(RAILS_ROOT,"tmp","gous", "gous.xml"))
    `curl -o #{file_path} #{['http://localhost:3000/sites/products_xml.xml?', "id=#{site_id}", "&catch_time=#{catch_time}"].join}`
    return unless File.exist?(file_path)
    doc = Nokogiri::XML(open(file_path))
    return doc
  end
  
end
