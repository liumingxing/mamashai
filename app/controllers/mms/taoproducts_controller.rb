require 'mamashai_tools/taobao_util'
require 'open-uri'
include MamashaiTools

class Mms::TaoproductsController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def from_mamashai
    @products = TaoProduct.paginate :page=>params[:page], :per_page => 100, :order=>"position desc,iid desc", :conditions=>"from_mamashai = 1"
    render :action=>"list"
  end

  def list
    if !params[:id]
      render :text=>"请从左边选择类目" and return
    end
    @category = TaoCategory.find(params[:id])
    conditions = ["category_id in (#{@category.category_ids.join(',')})"]
    @products = TaoProduct.paginate :page=>params[:page], :per_page => 100, :order=>"position desc,iid desc", :conditions=>conditions.join(' and ')
    @ages = Age.find(:all, :conditions=>"id > 2")
    @ages_hash = @ages.group_by(&:id)
    @recommends = RecommendProduct.all.map(&:taobao_product_id)
  end

  def recommend_product_list
    @categories = TaoCategory.find :all, :conditions => { :id => [1,2,3,5,357,277,338,314] }
    params[:category_id] = params[:category_id] || 1
    category = TaoCategory.find(params[:category_id])
    @leafs = TaoCategory.find :all, :conditions => ["id in (?)", category.leaf_ids]
    root_id = category.get_root
    if root_id.id == 4
      root_id = category.get_yun_root.id
    end
    @recommend_categories = RecommendCategory.find_all_by_taobao_category_id_and_position root_id, "index"
    recommends = RecommendProduct.find_all_by_taobao_category_id_and_position params[:category_id], "index"
    @re_hash = recommends.group_by &:taobao_product_id
    @products = TaoProduct.find(:all, :conditions => {:id => recommends.map(&:taobao_product_id)})
  end

  def flush_cache
    [1,2,3,5,357,277,338,314].each do |id|
      expire_fragment(:controller=>"index", :action=>"index", :category=> id)
    end
    render :text => "发布成功", :layout => false
  end

  def recommend_index
    product = TaoProduct.find_by_id params[:id]
    if product
      category = TaoCategory.find_by_id(product.category_id).get_root
      if category.id == 4
        category = TaoCategory.find_by_id(product.category_id).get_yun_root
      end
      RecommendProduct.create :taobao_product_id => product.id, :taobao_category_id => category.id, :position => "index"
      render :text => "推荐成功", :layout => false
      return
    end

    render :text => "推荐失败", :layout => false
    return
  end

  def cancle_recommend_index
    product = TaoProduct.find_by_id params[:id]
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
    product = TaoProduct.find_by_id params[:id]
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
    product = TaoProduct.find_by_id params[:id]
    if product
      RecommendProduct.find_by_taobao_product_id_and_position(product.id, "index").update_attribute(:queue, 0)
      render :text => "取消居中成功", :layout => false
      return
    end

    render :text => "取消居中失败", :layout => false
    return
  end

  def set_top
    product = TaoProduct.find_by_id params[:id]
    if product
      product.update_attribute :position, Time.new.to_i + 1000000000
      redirect_to :action=>"from_mamashai", :page=>params[:page]
      return
    end

    render :text => "置顶失败", :layout => false
    return
  end

  def cancel_top
    product = TaoProduct.find_by_id params[:id]
    if product
      product.update_attribute :position, nil
      redirect_to :action=>"from_mamashai", :id=>product.category_id, :page=>params[:page]
      return
    end

    render :text => "置顶取消失败", :layout => false
    return
  end

  def set_age
    age = Age.find_by_id params[:age]
    product = TaoProduct.find_by_id params[:id]
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
    products = TaoProduct.find :all, :conditions => ["id in (?)", params[:id].split(",")]
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
    product = TaoProduct.find_by_id params[:id]
    if product
      product.update_attribute :age, nil
      render :text => "年龄段已清空", :layout => false
      return
    end

    render :text => "操作失败", :layout => false
    return
  end
  
  def search
    @products = TaoProduct.paginate :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"from_mamashai = 1 and name like '%#{params[:name]}%'"
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
    @product = TaoProduct.find(params[:id])
  end

  def update
    @product = TaoProduct.find(params[:id])
    @product.update_attributes(params[:product])
    if @product.update_attributes(params[:product])
      if !params[:product][:tao_age_ids]
        TaoAgeTaoProduct.delete_all "tao_product_id = #{params[:id]}"
      end
      flash[:notice] = '修改商品成功.'
      redirect_to :action => 'list', :id=>@product.category_id
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
    product = TaoProduct.find(params[:id])
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
    @category = TaoCategory.find(params[:id])
    if params[:num_iid]
        access_params = {"num_iids"=>params[:num_iid],
          "fields" => "item_url,num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume",
        }
        
        res = MamashaiTools.taobao_call("taobao.tbk.items.detail.get", access_params)
        if res["tbk_items_detail_get_response"]["tbk_items"]
          @products = res["tbk_items_detail_get_response"]["tbk_items"]["tbk_item"]
        else
          @products = []
        end
    else
        access_params = {"keyword"=>params[:key],
          "start_commissionRate" => params[:start_commisionRate] || "300",
          "end_commissionRate" => params[:end_commisionRate] || "6000",
          "start_credit" => params[:start_credit] || "3diamond",
          "end_credit" => params[:end_credit] || "5goldencrown", "page_no" => params[:page]||"1",
          "sort"=>params[:sort]||'', "mall_item" => params[:mall_item] || "false",
          "fields" => "item_url,num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume",
        }
        
        res = MamashaiTools.taobao_call("taobao.tbk.items.get", access_params)
        logger.info access_params
        if res["tbk_items_get_response"]["tbk_items"]
          @products = res["tbk_items_get_response"]["tbk_items"]["tbk_item"]
        else
          @products = []
        end
    end
  end
  
  def create_from_api
    @category = TaoCategory.find_by_id(params[:id])
    access_params = {"num_iids"=>params[:num_iid].join(','),
      "fields" => "num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume"
    }
    
    res = MamashaiTools.taobao_call("taobao.tbk.items.detail.get", {"fields"=>"num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume,item_url", "num_iids"=>params[:num_iid].join(',')})
    if res['tbk_items_detail_get_response'] && res['tbk_items_detail_get_response']['total_results'] > 0
      products_json = res['tbk_items_detail_get_response']['tbk_items']['tbk_item']
      for product_json in products_json
        @product = TaoProduct.new
        @product.category_id = params[:id]
        @product.category_code = @category.code
        @product.url = product_json["item_url"]
        @product.name = product_json["title"]
        @product.pic_url = product_json["pic_url"]
        @product.iid = product_json["num_iid"]
        @product.price = product_json["price"]
        @product.volumn = product_json["volume"]


        @product.url_mobile = product_json["item_url"]
        #res_json = MamashaiTools.taobao_call("taobao.tbk.mobile.items.convert", {"fields"=>"click_url", "num_iids"=>product_json["num_iid"].to_s})
        #logger.info res_json
        #if res_json["tbk_mobile_items_convert_response"]["total_results"] == 1
        #  @product.url_mobile      = res_json["tbk_mobile_items_convert_response"]["tbk_items"]["tbk_item"][0]["click_url"]
        #end
        
        begin        
          token = Weibotoken.get('sina', 'babycalendar')
          user_weibo = UserWeibo.find(:first, :order=>"id desc")
          text = `curl 'https://api.weibo.com/2/short_url/shorten.json?url_long=#{URI.encode(@product.url_mobile)}&source=#{token.token}&access_token=#{user_weibo.access_token}'`
          res_json = JSON.parse(text)
          logger.info res_json
          if res_json['urls'] && res_json['urls'].size > 0
            @product.short_url = res_json['urls'][0]["url_short"]
          end
        rescue  Exception=>err
          logger.info err
        end
        
        #begin
        #  res = MamashaiTools.taobao_call("taobao.taobaoke.items.detail.get ", {"fields"=>"click_url,shop_click_url", "num_iids"=>params[:num_iid].join(',')})
        #  p res
        #  if res["taobaoke_items_detail_get_response"] && res["taobaoke_items_detail_get_response"]["taobaoke_item_details"]
        #    json = res["taobaoke_items_detail_get_response"]["taobaoke_item_details"]["taobaoke_item_detail"][0]
        #    @product.url = json["click_url"]
        #    @product.shop_url = json["shop_click_url"]
        #  end
        #rescue Exception => err
        #  logger.info err
        #end


        @product.save


      end
    end
    
    render :text=>"ok"
  end
  
  def new_from_tmall_best
    @category = TaoCategory.find_by_id(params[:id])
    @products = MamashaiTools.taobao_call("tmall.selected.items.search", {"cid"=>params[:code], "sort"=>"s"})
  end
  
  def get_comments
    product = ::TaoProduct.find(params[:id])
    product.get_comments()
    #render :text=>""
    redirect_to :action=>"list", :id=>product.category_id, :page => params[:page]
  end

  def change_category
    for id in params[:p]
      product = TaoProduct.find_by_id(id)
      if product
        product.category_id = params[:category_id]
        product.save
      end
    end if params[:p]
    redirect_to :action=>"list", :id=>params[:id], :page=>params[:page], :category_id=>params[:category_id]
  end

  def delete_products
    if params[:commit] == "设置"
      for id in params[:p]
        product = TaoProduct.find_by_id(id)
        product.category_id = params[:new_category_id] if product
        product.save
      end if params[:p] && params[:new_category_id]

      redirect_to :action=>"list", :id=>params[:id], :page=>params[:page], :category_id=>params[:category_id]
      return
    else
      for id in params[:p]
        product = TaoProduct.find_by_id(id)
        product.destroy if product
      end if params[:p]
      redirect_to :action=>"list", :id=>params[:id], :page=>params[:page]
    end

  end

  def recommand
    if TaoRecommand.find_by_tao_product_id(params[:id])
      render :text=>"已推荐" and return
    end

    TaoRecommand.create(:tao_product_id=>params[:id])
    render :text=>"推荐成功"
  end

  def recommands
    @recommands = TaoRecommand.all()
  end

  def delete_recommand
      TaoRecommand.destroy(params[:id])
      redirect_to :action=>"recommands"
  end
end
