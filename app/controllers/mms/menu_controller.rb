class Mms::MenuController < Mms::MmsBackEndController
  def index
    @menu = Mms::Menu.new
    @roots = Mms::Menu.find(:all, :order=>"position", :conditions=>"parent_id is null or parent_id=''")
  end

  def show
    @menu = Mms::Menu.find(params[:id])
  end

  def new
    @menu = Mms::Menu.new
    @menu.parent_id = params[:parent]
    render :layout=>false
  end

  def create
    @menu = Mms::Menu.new(params[:menu])
    if @menu.save
      #flash[:notice] = '新建节点成功'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @menu = Mms::Menu.find(params[:id])
    render :action => "edit", :layout =>false
  end

  def update
    @menu = Mms::Menu.find(params[:id])
    if @menu.update_attributes(params[:menu])
      #flash[:notice] = '修改节点信息成功'
      #redirect_to :action => 'index'
      render :text=>"修改节点信息成功"
    else
      render :action => 'edit'
    end
  end

  def destroy
    Mms::Menu.find(params[:id]).destroy
    render :text=>"删除节点成功"
    #redirect_to :action => 'index'
  end
  
  def getchildnode    
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"
    parent = Mms::Menu.find(params[:id])
    for child in parent.children
      next if !@mms_user.menus.include?(child)
      src = "/mms/menu/getchildnode/#{child.id}"
      src = "" if child.children.length == 0
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.length == 0
      doc += "<tree text='#{child.text}' 
              src='#{src}' 
              icon='#{img}' 
              openIcon='#{img}' 
              clickFunc=\" $('#editdiv').load('/mms/menu/edit/#{child.id}'); return false; \"
              >"
      doc += "</tree>"
    end
    
    doc += '</treeRoot>'
    send_data doc, :type =>"text/xml"
  end
  
  def getchildnode_action
    doc = "<?xml version='1.0' encoding='UTF-8'?><treeRoot>"

   begin
    parent = Mms::Menu.find(:first, :conditions=>"id=#{params[:id]}")
   rescue Exception => e
      p e
    end
    for child in parent.children
      next if child.hide == 1
      next if !@mms_user.menus.include?(child)
      
      src = "/mms/menu/getchildnode_action/#{child.id}"
      src = "" if child.children.length == 0
      #action = child.url
      img = "/img/icon_9.png"
      img = "/img/icon_0.png" if child.children.length == 0
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
  
  def reorder
    @node = Mms::Menu.find(params[:id])
  end
  
  def order
    index = 1
    for node in params[:nodelist]
      child = Mms::Menu.find(node)
      child.position = index
      child.save
      index += 1
    end
    
    render :text=>'排序成功'
  end

  #设定某个用户的权限
  def right
    @menus = Mms::Menu.find(:all, :order=>"parent_id, position")
    @menu_ids = Mms::User.find(params[:id]).menus.collect{|r| r.id}
  end
  
  def set_right
    Mms::MenuUser.delete_all "user_id = #{params[:id]}"
    for id in params[:checked_values].split(',')
      next if !id || id == ''
      r = Mms::MenuUser.new(:user_id => params[:id], :menu_id => id)
      r.save
    end
    flash[:notice] = "设定权限成功"
    redirect_to "/mms/users/index"
  end
  
  #设定某个权限哪些用户可以看见
  def user
    @users = Mms::User.find(:all)
    @user_ids = Mms::Menu.find(params[:id]).users.collect{|u| u.user_id}
  end
  
  def set_user
    Mms::MenuUser.delete_all "menu_id = #{params[:id]}"
    for id in params[:checked_values].split(',')
      next if !id || id == ''
      r = Mms::MenuUser.new(:menu_id => params[:id], :user_id => id)
      r.save
    end
    flash[:notice] = "设定权限成功"
    redirect_to "/mms/menu/index"
  end
end
