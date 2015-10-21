require 'mamashai_tools/taobao_util'
require 'open-uri'
include MamashaiTools

class Mms::TaobaoproductsController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    if !params[:id]
      render :text=>"请从左边选择类目" and return
    end
    @category = Mms::TaobaoCategory.find(params[:id])
    conditions = ["category_id in (#{@category.category_ids.join(',')})"]
    @products = Mms::TaobaoProduct.paginate :page=>params[:page], :per_page => 10, :order=>"id desc", :conditions=>conditions.join(' and ')
    @ages = Age.find(:all, :conditions=>"id > 2")
    @ages_hash = @ages.group_by(&:id)
    @recommends = RecommendProduct.all.map(&:taobao_product_id)
  end

  def recommend_product_list
    @categories = TaobaoCategory.find :all, :conditions => { :id => [1,2,3,5,357,277,338,314] }
    params[:category_id] = params[:category_id] || 1
    category = Mms::TaobaoCategory.find(params[:category_id])
    @leafs = Mms::TaobaoCategory.find :all, :conditions => ["id in (?)", category.leaf_ids]
    root_id = category.get_root
    if root_id.id == 4
      root_id = category.get_yun_root.id
    end
    @recommend_categories = RecommendCategory.find_all_by_taobao_category_id_and_position root_id, "index"
    recommends = RecommendProduct.find_all_by_taobao_category_id_and_position params[:category_id], "index"
    @re_hash = recommends.group_by &:taobao_product_id
    @products = Mms::TaobaoProduct.find(:all, :conditions => {:id => recommends.map(&:taobao_product_id)})
  end

  def flush_cache
    [1,2,3,5,357,277,338,314].each do |id|
      expire_fragment(:controller=>"index", :action=>"index", :category=> id)
    end
    render :text => "发布成功", :layout => false
  end

  def recommend_index
    product = TaobaoProduct.find_by_id params[:id]
    if product
      category = Mms::TaobaoCategory.find_by_id(product.category_id).get_root
      if category.id == 4
        category = Mms::TaobaoCategory.find_by_id(product.category_id).get_yun_root
      end
      RecommendProduct.create :taobao_product_id => product.id, :taobao_category_id => category.id, :position => "index"
      render :text => "推荐成功", :layout => false
      return
    end

    render :text => "推荐失败", :layout => false
    return
  end

  def cancle_recommend_index
    product = TaobaoProduct.find_by_id params[:id]
    if product
      RecommendProduct.find_by_taobao_product_id_and_position(product.id, "index").destroy
      render :text => "取消推荐成功", :layout => false
      return
    end

    render :text => "取消推荐失败", :layout => false
    return
  end

  def recommend_category
    ids = params[:ids].split(",")
    recommends = RecommendCategory.find_all_by_taobao_category_id_and_position params[:category_id], "index"
    unless recommends.blank?
      recommends.each do |r|
        r.destroy
      end
    end
    ids.each do |id|
      RecommendCategory.create :category_id => id, :taobao_category_id => params[:category_id]
    end
    render :text => "类目推荐成功", :layout => false
    return
  end

  def set_middle
    product = TaobaoProduct.find_by_id params[:id]
    if product
      middle = RecommendProduct.find_by_taobao_category_id_and_queue params[:category_id], 1
      if middle
        render :text => "已有居中大图显示的商品，如要设置新的，请先将原来的取消居中显示", :layout => false
        return
      else
        RecommendProduct.find_by_taobao_product_id_and_position(product.id, "index").update_attribute(:queue, 1)
      end
      render :text => "设置居中成功", :layout => false
      return
    end

    render :text => "设置居中失败", :layout => false
    return
  end

  def cancle_middle
    product = TaobaoProduct.find_by_id params[:id]
    if product
      RecommendProduct.find_by_taobao_product_id_and_position(product.id, "index").update_attribute(:queue, 0)
      render :text => "取消居中成功", :layout => false
      return
    end

    render :text => "取消居中失败", :layout => false
    return
  end

  def set_top
    product = TaobaoProduct.find_by_id params[:id]
    if product
      product.update_attribute :is_top, Time.new.to_i
      render :text => "置顶成功", :layout => false
      return
    end

    render :text => "置顶失败", :layout => false
    return
  end

  def cancle_top
    product = TaobaoProduct.find_by_id params[:id]
    if product
      product.update_attribute :is_top, 0
      render :text => "置顶取消成功", :layout => false
      return
    end

    render :text => "置顶取消失败", :layout => false
    return
  end

  def set_age
    age = Age.find_by_id params[:age]
    product = TaobaoProduct.find_by_id params[:id]
    if product and age
      product_age = product.age.to_s.split(",")
      product_age.delete("")
      product_age << age.id
      product_age = "," + product_age.join(",") + ","
      product.update_attribute :age, product_age
      render :text => "设置年龄段成功", :layout => false
      return
    end

    render :text => "设置年龄段失败", :layout => false
    return
  end

  def set_ages
    age = Age.find_by_id params[:age]
    products = TaobaoProduct.find :all, :conditions => ["id in (?)", params[:id].split(",")]
    if !products.blank? and age
      products.each do |product|
        product_age = product.age.to_s.split(",")
        product_age.delete("")
        product_age << age.id
        product_age = "," + product_age.join(",") + ","
        product.update_attribute :age, product_age
      end
      render :text => "批量设置年龄段成功", :layout => false
      return
    end

    render :text => "批量设置年龄段失败", :layout => false
    return
  end

  def delete_age
    product = TaobaoProduct.find_by_id params[:id]
    if product
      product.update_attribute :age, nil
      render :text => "年龄段已清空", :layout => false
      return
    end

    render :text => "操作失败", :layout => false
    return
  end
  
  def search
    @category = Mms::TaobaoCategory.new
    @products = Mms::TaobaoProduct.paginate :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"name like '%#{params[:name]}%'"
    @ages = Age.find(:all, :conditions=>"id > 2")
    @ages_hash = @ages.group_by(&:id)
    @recommends = RecommendProduct.all.map(&:taobao_product_id)
    render :action=>"list"
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @category = Category.find_by_id(params[:id])
    @product = Product.new
    @product.platform = @category.platform
    @product.age = @category.age
    @product.sex = @category.sex
    @product.step1 = @category.step1
    @product.step2 = @category.step2
  end
  
  def new_from_url
    new()
    @product.parse(params[:url])
    render :action=>"new"
  end

  def create
    @product = Product.new(params[:product])
    @product.platform = params[:platform].join(",") if params[:platform]
    @product.age = params[:age].join(",") if params[:age]
    @product.step1 = params[:step1].join(",") if params[:step1]
    @product.step2 = params[:step2].join(",") if params[:step2]
    @product.sex = params[:sex].join(",") if params[:sex]
    @product.inputer = session[:user_name]
    if @product.save
      r = CategoryProduct.create(:t=>"product", :category_id=>params[:id], :product_id=>@product.id)
      
      flash[:notice] = '添加商品成功.'
      redirect_to :action => 'list', :id=>params[:id]
    else
      flash[:notice] = "有重复名称"
      render :action => 'new', :id=>params[:id]
    end
  end

  def edit
    @product = TaobaoProduct.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    @product.platform = params[:platform].join(",") if params[:platform]
    @product.age = params[:age].join(",") if params[:age]
    @product.step1 = params[:step1].join(",") if params[:step1]
    @product.step2 = params[:step2].join(",") if params[:step2]
    @product.sex = params[:sex].join(",") if params[:sex]
    if @product.update_attributes(params[:product])
      flash[:notice] = '修改商品成功.'
      redirect_to :action => 'list', :id=>params[:category_id], :age=>params[:tt]
    else
      render :action => 'edit'
    end
  end
  
  def add_exist_product
    CategoryProduct.create(:t=>"product", :category_id=>params[:category_id], :product_id=>params[:product_id]) rescue nil
    flash[:notice] = "添加成功"
    redirect_to :action=>"list", :id=>params[:category_id]
  end

  def destroy_relation
    CategoryProduct.delete_all("t='product' and product_id = #{params[:product_id]} and category_id = #{params[:category_id]}")
    redirect_to :action => 'list', :id=>params[:category_id]
  end
  
  def destroy
    product = TaobaoProduct.find(params[:id])
    product.destroy
    redirect_to :action => 'list', :id=>product.category_id, :page => params[:page]
  end
  
  def level2_of
    @category = Category.find(params[:id])
    render :partial=>"level2_of"
  end
  
  def level3_of
    @category = Category.find(params[:id])
    render :partial=>"level3_of"
  end
  
  def new_from_api
    access_params = {"keyword"=>params[:key],
      "start_commissionRate" => params[:start_commisionRate] || "100",
      "end_commissionRate" => params[:end_commisionRate] || "6000",
      "start_credit" => params[:start_credit] || "3diamond",
      "end_credit" => params[:end_credit] || "5goldencrown", "page_no" => params[:page]||"1",
      "sort"=>params[:sort]||'', "mall_item" => params[:mall_item] || "false",
      "fields" => "num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume",
      'pid'=>'31724749'
    }
    
    res = MamashaiTools.taobao_call("taobao.taobaoke.items.get", access_params)
    #logger.info res
    @category = TaobaoCategory.find(params[:id])
    if res["taobaoke_items_get_response"]["taobaoke_items"]
      @products = res["taobaoke_items_get_response"]["taobaoke_items"]["taobaoke_item"]
    else
      @products = []
    end
  end
  
  def create_from_api
    @category = Mms::TaobaoCategory.find_by_id(params[:id])
    access_params = {"num_iids"=>params[:num_iid].join(','), 'pid'=>'31724749',
      "fields" => "num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume"
    }
    
    res = MamashaiTools.taobao_call("taobao.taobaoke.items.convert", {"fields"=>"num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume", "num_iids"=>params[:num_iid].join(','), 'pid'=>'31724749', 'is_mobile'=>"false"})
    
    if res['taobaoke_items_convert_response'] && res['taobaoke_items_convert_response']['taobaoke_items']
      products_json = res['taobaoke_items_convert_response']['taobaoke_items']['taobaoke_item']
      for product_json in products_json
        @product = Mms::TaobaoProduct.new
        @product.category_id = params[:id]
        @product.category_code = @category.code
        @product.url = product_json["click_url"]
        @product.name = product_json["title"]
        @product.pic_url = product_json["pic_url"]
        @product.iid = product_json["num_iid"]
        @product.price = product_json["price"]
        @product.shop_url = product_json["shop_click_url"]
        
        @product.location = product_json["item_location"]
        @product.volumn = product_json["volume"]
        @product.commission = product_json["commission"]
        @product.commission_num = product_json["commission_num"]
          
        @product.save
      end
    end
    
    render :text=>"ok"
  end
  
  def new_from_tmall_best
    @category = Mms::TaobaoCategory.find_by_id(params[:id])
    @products = MamashaiTools.taobao_call("tmall.selected.items.search", {"cid"=>params[:code], "sort"=>"s"})
    p @products
  end
  
  def get_comments
    product = ::TaobaoProduct.find(params[:id])
    product.get_comments()
    #render :text=>""
    redirect_to :action=>"list", :id=>product.category_id, :page => params[:page]
  end
end
