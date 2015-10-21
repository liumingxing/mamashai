class Mms::TaoCategoriesController < Mms::MmsBackEndController
  
  def select_interface
    render :layout=>false
  end

  def index
    @category = TaoCategory.new
    
    @roots = TaoCategory.find(:all, :order=>"id", :conditions=>"parent_id is null or parent_id=''")
  end
  
  def products
    @roots = TaoCategory.find(:all, :order=>"id", :conditions=>"parent_id is null or parent_id=''")
  end
  
  def brands
    @roots = TaoCategory.find(:all, :order=>"id", :conditions=>"parent_id is null or parent_id=''")
  end
  
  def shops
    @roots = TaoCategory.find(:all, :order=>"id", :conditions=>"parent_id is null or parent_id=''")
  end

  def merge_category
    category = TaoCategory.find_by_id params[:current_id]
    other = TaoCategory.find_by_id params[:other_category]
    if category and other and category.is_parent.blank? and other.is_parent.blank? and category.parent_id == other.parent_id
      TaoProduct.find_all_by_category_id(category.id).each do |p|
        p.update_attribute :category_id, other.id
      end
      render :text => "合并类目成功", :layout => false
      return
    end
    render :text => "合并类目失败", :layout => false
  end

  def show
    @category = TaoCategory.find(params[:id])
  end

  def new
    @category = TaoCategory.new
    @category.parent_id = params[:parent]
    
    @parent_category = TaoCategory.find_by_id(params[:parent])
    render :layout=>false
  end

  def create
    @category = TaoCategory.new(params[:category])
    @category.platform = params[:platform].join(",") if params[:platform]
    @category.age = params[:age].join(",") if params[:age]
    
    if @category.save
      #flash[:notice] = '新建节点成功'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @category = TaoCategory.find(params[:id])
    render :action => "edit", :layout =>false
  end

  def update
    @category = TaoCategory.find(params[:id])
    @category.platform = params[:platform].join(",") if params[:platform]
    @category.age = params[:age].collect{|a| a + ","}.join("") if params[:age]
    if @category.update_attributes(params[:category])
      if !params[:category][:tao_age_ids]
        TaoAgeTaoCategory.delete_all "tao_category_id = #{params[:id]}"
      end
      render :text=>"修改节点信息成功"
    else
      render :action => 'edit'
    end
  end

  def destroy
    category = TaoCategory.find_by_id(params[:id])
    category.delete if category
    render :text=>"删除节点成功"
    #redirect_to :action => 'index'
  end
  
  def getchildnode    
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
    parent = TaoCategory.find(params[:id])
    for child in parent.children
      next if child.code == "-1"
      src = "/mms/tao_categories/getchildnode/#{child.id}"
      src = "" if child.children.size == 0
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.size == 0
      doc += "<tree text='#{child.name} #{child.children.size>0 ? "(" + child.children.size.to_s + ")" : ""}' 
              src='#{src}' 
              icon='#{img}' 
              openIcon='#{img}' 
              clickFunc=\" $('#editdiv').load('/mms/tao_categories/edit/#{child.id}'); return false; \"
              >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    send_data doc, :type =>"text/xml"
  end
  
  def getchildnode2
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
    parent = TaoCategory.find(params[:id])
    for child in parent.children
      next if child.code == "-1"
      src = "/mms/tao_categories/getchildnode2/#{child.id}"
      src = "" if child.children.size == 0
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.size == 0
      doc += "<tree text='#{child.name} #{child.children.size>0 ? "(#{child.children.size.to_s})" : "(#{child.products_count})"} (id:#{child.id})' 
              src='#{src}' 
              icon='#{img}' 
              openIcon='#{img}'
              action = '/mms/taoproducts/list/#{child.id}' 
              target='products'
              >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    send_data doc, :type =>"text/xml"
  end
  
  def getchildnode3
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
    parent = TaoCategory.find(params[:id])
    for child in parent.children
      src = "/mms/categories/getchildnode3/#{child.id}"
      src = "" if child.children.size == 0
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.size == 0
      doc += "<tree text='#{child.name} #{child.children.size>0 ? "(" + child.children.size.to_s + ")" : ""}' 
              src='#{src}' 
              icon='#{img}' 
              openIcon='#{img}'
              action = '/brands/list/#{child.id}' 
              target='brands'
              >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    send_data doc, :type =>"text/xml"
  end
  
  def getchildnode4
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
    parent = TaoCategory.find(params[:id])
    for child in parent.children
      src = "/mms/categories/getchildnode4/#{child.id}"
      src = "" if child.children.size == 0
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.size == 0
      doc += "<tree text='#{child.name}' 
              src='#{src}' 
              icon='#{img}' 
              openIcon='#{img}'
              action = '/shops/list/#{child.id}' 
              target='brands'
              >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    send_data doc, :type =>"text/xml"
  end
  
  def getchildnode_action
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"

   begin
    parent = TaoCategory.find(:first, :conditions=>"id=#{params[:id]}")
   rescue Exception => e
      p e
    end
    for child in parent.children
      next if child.hide == 1
      next if !@mms_user.menus.include?(child)
      
      src = "/mms/menu/getchildnode_action/#{child.id}"
      src = "" if child.children.size == 0
      #action = child.url
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.size == 0
      content = "content"
      content = "_blank" if child.blank == 1
      
      text = child.text
      text = instance_eval(child.text) if child.text.index('"')  || child.text.index("'")
      url = child.url
      url =  instance_eval(url) if url && (url.index('"') || url.index("'"))
      doc += "<tree text='#{text}' 
              src='#{src}' 
              icon='#{img}' 
              openIcon='#{img}' 
              action='#{url}'
              target='#{content}'
              >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    send_data doc, :type =>"text/xml"
  end
  
  def level2_of
    @category = TaoCategory.find(params[:id])
    render :partial=>"level2_of"
  end
  
  def level3_of
    @category = TaoCategory.find(params[:id])
    render :partial=>"level3_of"
  end
  
  def reorder
    @node = TaoCategory.find(params[:id])
  end
  
  def order
    index = 1
    for node in params[:nodelist]
      child = TaoCategory.find(node)
      child.id = index
      child.save
      index += 1
    end
    
    render :text=>'排序成功'
  end
  
  def update_price
    for product in TaoProduct.find(:all, :conditions=>"iid is not null")
      product.update_price
    end
    render :text=>"更新完毕"
  end

  def delete_products
    TaoProduct.delete_all("category_id = #{params[:id]}")
    render :text=>"删除商品成功"
  end

  def score
    @events = ScoreEvent.paginate(:page=>params[:page], :per_page=>20, :conditions=>"event = 'tiexingou'", :order=>"id desc")
  end

  def make_score
    taobao = UserTaobao.find_by_taobao_nick(params[:nick], :order=>"id desc")
    render :text=>"此人未关联宝宝日历账户" and return if !taobao || !taobao.user
    render :text=>"请输入正确价格" and return if params[:price].to_i < 1

    score = params[:price].to_i/5
    ScoreEvent.create(:event=>"tiexingou", :score=>score, :user_id=>taobao.user_id, :total_score=>taobao.user.score + score, :unit=>1, :event_description=>"贴心购返豆")
    taobao.user.score += score
    taobao.user.save

    render :text=>"成功返了#{score}个豆"
  end

  def add_product
      num_iid = params[:iid]
      txt = `curl http://hws.m.taobao.com/cache/wdetail/5.0/?id=#{num_iid}&ttid=2013@taobao_h5_1.0.0&exParams={}`
      json = ActiveSupport::JSON.decode(txt)
      json2 = ActiveSupport::JSON.decode(json["data"]["apiStack"].first["value"])
      
      @product = TaoProduct.find_by_iid(num_iid)
      @product = TaoProduct.new if !@product
      @product.category_id = 1603 if !@product.category_id
      @product.url = json["data"]["itemInfoModel"]["itemUrl"]
      @product.name = json["data"]["itemInfoModel"]["title"]
      @product.pic_url = json["data"]["itemInfoModel"]["picsPath"][0]
      @product.iid = num_iid
      @product.from_mamashai = true
      @product.price = json2["data"]["itemInfoModel"]["priceUnits"].first["price"]
      @product.o_price = json2["data"]["itemInfoModel"]["priceUnits"][1]["price"] if json2["data"]["itemInfoModel"]["priceUnits"].size > 1
      @product.url_mobile = json["data"]["itemInfoModel"]["itemUrl"]
      begin        
            token = Weibotoken.get('sina', 'babycalendar')
            user_weibo = UserWeibo.find(:first, :order=>"id desc")
            text = `curl 'https://api.weibo.com/2/short_url/shorten.json?url_long=#{URI.encode(@product.url_mobile)}&source=#{token.token}&access_token=#{user_weibo.access_token}'`
            res_json = JSON.parse(text)
            if res_json['urls'] && res_json['urls'].size > 0
              @product.short_url = res_json['urls'][0]["url_short"]
            end
      rescue  Exception=>err
            logger.info err
      end

      @product.save

      flash[:notice] = "添加成功"
      redirect_to :action=>"new_from_iid"
  end
end
