namespace :mamashai do
  desc "create gous.  "
  task :create_gous  => [:environment] do
    @category_map = {}
    @brand_map = {}
    @error_map = []
    @logo = File.new(File.join(RAILS_ROOT,"public","images","dianping","logos_thumb.jpg"))
    RedboyProduct.find_each do |product|
      #分类处理
      ActiveRecord::Base.transaction do
        category_name = product.category_name
        next if @error_map.include?(category_name)
        category = get_category(category_name)
        next if category.blank?
        
        #品牌处理
        brand_name = product.brand.gsub(/\s|品　　牌：/,'')
        brand = get_brand(brand_name)
        
        #开始处理redboy
        gou = Gou.new(:name=>product.product_name.strip,:standard=>product.standard.gsub(/\s|规　　格：|(,)$/,''),:price=>product.sell_price,:content=>product.intro,:link=>product.url)
        gou.gou_category = category
        gou.gou_brand = brand
        gou.logo = @logo
        gou.save
      end
    end
  end
  
  def get_category(name)
    return @category_map[name] if @category_map.include?(name)
    category = GouCategory.get_category(name)
    if category.present?
      @category_map[name] = category
      return @category_map[name]
    else
      @error_map << name
      return
    end
  end
  
  def get_brand(name)
    return @brand_map[name] if @brand_map.include?(name)
    brand = GouBrand.create_brand(name)
    @brand_map[name]=brand
  end
  
end