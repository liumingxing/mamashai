class Mms::CategoriesController < Mms::MmsBackEndController
  
  def select_interface
    render :layout=>false
  end

  def index
    @category = Mms::TaobaoCategory.new
    
    @roots = Mms::TaobaoCategory.find(:all, :order=>"id", :conditions=>"parent_id is null or parent_id=''")
  end
  
  def products
    @roots = Mms::TaobaoCategory.find(:all, :order=>"id", :conditions=>"parent_id is null or parent_id=''")
  end
  
  def brands
    @roots = Mms::TaobaoCategory.find(:all, :order=>"id", :conditions=>"parent_id is null or parent_id=''")
  end
  
  def shops
    @roots = Mms::TaobaoCategory.find(:all, :order=>"id", :conditions=>"parent_id is null or parent_id=''")
  end

  def merge_category
    category = Mms::TaobaoCategory.find_by_id params[:current_id]
    other = Mms::TaobaoCategory.find_by_id params[:other_category]
    if category and other and category.is_parent.blank? and other.is_parent.blank? and category.parent_id == other.parent_id
      Mms::TaobaoProduct.find_all_by_category_id(category.id).each do |p|
        p.update_attribute :category_id, other.id
      end
      render :text => "合并类目成功", :layout => false
      return
    end
    render :text => "合并类目失败", :layout => false
  end

  def show
    @category = Mms::TaobaoCategory.find(params[:id])
  end

  def new
    @category = Mms::TaobaoCategory.new
    @Mms::TaobaoCategory.parent_id = params[:parent]
    
    @parent_category = Mms::TaobaoCategory.find_by_id(params[:parent])
    render :layout=>false
  end

  def create
    @category = Mms::TaobaoCategory.new(params[:category])
    @category.platform = params[:platform].join(",") if params[:platform]
    @category.age = params[:age].join(",") if params[:age]
    @category.inputer = session[:mms_user]
    
    if @category.save
      #flash[:notice] = '新建节点成功'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @category = Mms::TaobaoCategory.find(params[:id])
    render :action => "edit", :layout =>false
  end

  def update
    @category = Mms::TaobaoCategory.find(params[:id])
    @category.platform = params[:platform].join(",") if params[:platform]
    @category.age = params[:age].collect{|a| a + ","}.join("") if params[:age]
    if @category.update_attributes(params[:category])
      render :text=>"修改节点信息成功"
    else
      render :action => 'edit'
    end
  end

  def destroy
    Mms::TaobaoCategory.find(params[:id]).destroy
    render :text=>"删除节点成功"
    #redirect_to :action => 'index'
  end
  
  def getchildnode    
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
    parent = Mms::TaobaoCategory.find(params[:id])
    for child in parent.children
      src = "/mms/categories/getchildnode/#{child.id}"
      src = "" if child.children.size == 0
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.size == 0
      doc += "<tree text='#{child.name} #{child.children.size>0 ? "(" + child.children.size.to_s + ")" : ""}' 
              src='#{src}' 
              icon='#{img}' 
              openIcon='#{img}' 
              clickFunc=\" $('#editdiv').load('/mms/categories/edit/#{child.id}'); return false; \"
              >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    send_data doc, :type =>"text/xml"
  end
  
  def getchildnode2
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
    parent = Mms::TaobaoCategory.find(params[:id])
    for child in parent.children
      src = "/mms/categories/getchildnode2/#{child.id}"
      src = "" if child.children.size == 0
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.size == 0
      doc += "<tree text='#{child.name} #{child.children.size>0 ? "(#{child.children.size.to_s})" : "(#{child.products_count})"}' 
              src='#{src}' 
              icon='#{img}' 
              openIcon='#{img}'
              action = '/mms/taobaoproducts/list/#{child.id}' 
              target='products'
              >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    send_data doc, :type =>"text/xml"
  end
  
  def getchildnode3
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
    parent = Mms::TaobaoCategory.find(params[:id])
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
    parent = Mms::TaobaoCategory.find(params[:id])
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
    parent = Mms::TaobaoCategory.find(:first, :conditions=>"id=#{params[:id]}")
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
    @category = Mms::TaobaoCategory.find(params[:id])
    render :partial=>"level2_of"
  end
  
  def level3_of
    @category = Mms::TaobaoCategory.find(params[:id])
    render :partial=>"level3_of"
  end
  
  def reorder
    @node = Mms::TaobaoCategory.find(params[:id])
  end
  
  def order
    index = 1
    for node in params[:nodelist]
      child = Mms::TaobaoCategory.find(node)
      child.id = index
      child.save
      index += 1
    end
    
    render :text=>'排序成功'
  end
  
  def update_price
    for product in TaobaoProduct.find(:all, :conditions=>"iid is not null")
      product.update_price
    end
    render :text=>"更新完毕"
  end
end
