require 'mamashai_tools/taobao_util'
require 'open-uri'
include MamashaiTools

class Mms::TaoTopicsController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end
  
  def list
    @tao_topics = TaoTopic.paginate :page=>params[:page], :per_page => 10, :order=>"id desc"
  end

  def show
    @tao_topic = TaoTopic.find(params[:id])
  end

  def new
    @tao_topic = TaoTopic.new
  end

  def create
    @tao_topic = TaoTopic.new(params[:tao_topic])
    if @tao_topic.save
      flash[:notice] = 'TaoTopic was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tao_topic = TaoTopic.find(params[:id])
  end

  def update
    @tao_topic = TaoTopic.find(params[:id])
    if @tao_topic.update_attributes(params[:tao_topic])
      flash[:notice] = 'TaoTopic was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    TaoTopic.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def products
    @topic = TaoTopic.find(params[:id])
  end

  def new_from_api
    params[:key] = "婴儿用品" if !params[:key] || params[:key] == ""
    access_params = {"keyword"=>params[:key],
      "start_commissionRate" => params[:start_commisionRate] || "300",
      "end_commissionRate" => params[:end_commisionRate] || "6000",
      "start_credit" => params[:start_credit] || "3diamond",
      "end_credit" => params[:end_credit] || "5goldencrown", "page_no" => params[:page]||"1",
      "sort"=>params[:sort]||'', "mall_item" => params[:mall_item] || "false",
      "fields" => "item_url,num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume",
    }

    if params[:cid] && params[:cid].size > 0
      access_params["cid"] = params[:cid]
    end
    
    res = MamashaiTools.taobao_call("taobao.tbk.items.get", access_params)
    logger.info res
    @topic = TaoTopic.find(params[:id])
    if res["tbk_items_get_response"]["tbk_items"]
      @products = res["tbk_items_get_response"]["tbk_items"]["tbk_item"]
    else
      @products = []
    end

  end

  def create_from_api
    res = MamashaiTools.taobao_call("taobao.tbk.items.detail.get", {"fields"=>"num_iid,cid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume,item_url", "num_iids"=>params[:num_iid].join(',')})
    
    if res['tbk_items_detail_get_response'] && res['tbk_items_detail_get_response']['total_results'] > 0
      products_json = res['tbk_items_detail_get_response']['tbk_items']['tbk_item']
      for product_json in products_json
        @product = TaoProduct.find_by_iid(product_json["num_iid"])
        @product = TaoProduct.new if !@product
        @product.tao_topic_id = params[:id]
        @product.url = product_json["item_url"]
        @product.name = product_json["title"]
        @product.pic_url = product_json["pic_url"]
        @product.iid = product_json["num_iid"]
        @product.price = product_json["price"]
        @product.volumn = product_json["volume"]

        res_json = MamashaiTools.taobao_call("taobao.tbk.mobile.items.convert", {"fields"=>"click_url", "num_iids"=>product_json["num_iid"].to_s})
        logger.info res_json
        if res_json["tbk_mobile_items_convert_response"]["total_results"] == 1
          @product.url_mobile      = res_json["tbk_mobile_items_convert_response"]["tbk_items"]["tbk_item"][0]["click_url"]
        end
        
        begin        
          token = Weibotoken.get('sina', 'babycalendar')
          user_weibo = UserWeibo.find(:first, :order=>"id desc")
          text = `curl 'https://api.weibo.com/2/short_url/shorten.json?url_long=#{URI.encode(@product.url_mobile)}&source=#{token.token}&access_token=#{user_weibo.access_token}'`
          res_json = JSON.parse(text)
          p res_json
          if res_json['urls'] && res_json['urls'].size > 0
            @product.short_url = res_json['urls'][0]["url_short"]
          end
        rescue  Exception=>err
          p err
        end

        @product.save
      end
    end
    
    res = MamashaiTools.taobao_call("taobao.taobaoke.items.detail.get", {"fields"=>"num_iid,cid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume", "num_iids"=>params[:num_iid].join(','),  'is_mobile'=>"true"})
    p res
    if res['taobaoke_items_detail_get_response'] && res['taobaoke_items_detail_get_response']['taobaoke_item_details']
      products_json = res['taobaoke_items_detail_get_response']['taobaoke_item_details']['taobaoke_item_detail']
      for product_json in products_json
        product = TaoProduct.find_by_iid(product_json["item"]["num_iid"])
        product.category_code = product_json["item"]['cid']
        category = TaoCategory.find_by_code(product_json["item"]["cid"])
        product.category_id = category.id if category
        product.save
      end
    end
    render :text=>"ok"
  end

  def new_from_local
    @topic = TaoTopic.find(params[:id])
    conditions = ['1=1']
    conditions << "category_id = #{params[:cid]}" if params[:cid]
    conditions << "name like '%#{params[:key]}%'" if params[:key] && params[:key].size > 0
    @products = TaoProduct.paginate(:page=>params[:page], :per_page=>15, :conditions=>conditions.join(' and '))
  end

  def create_from_local
    for id in params[:ids]
      product = TaoProduct.find(id)
      product.tao_topic_id = params[:id]
      product.save
    end
  end

  def destroy_product
    product = TaoProduct.find(params[:product_id])
    product.destroy

    redirect_to :action=>"products", :id=>params[:id]
  end

  def delete_products
    for id in params[:ids]
      product = TaoProduct.find(id)
      product.tao_topic_id = nil
      product.save
    end
    redirect_to :action=>"products", :id=>params[:id]
  end
end
