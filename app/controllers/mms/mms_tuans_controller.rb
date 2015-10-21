# -*- coding: utf-8 -*-
class Mms::MmsTuansController < Mms::MmsBackEndController
  
  uses_tiny_mce(:options => Article.tiny_advance_options,:only => [:new, :edit,:create,:update])
  
  def index
    page = params[:page] || 1
    @tuans = ::Tuan.mms.paginate( :per_page => 20, :page =>page, :include=>[:tuan_website], :order=>"created_at desc")
  end
  
  def search
    page = params[:page] || 1
    @keyword = params[:keyword] || ""
    @tuans = ::Tuan.mms.paginate(:per_page => 20, :page => page , :conditions=>["(content like ? or introduction like ?)", "%"+@keyword+"%", "%"+@keyword+"%"], :include => [:tuan_website], :order => "created_at DESC")
    render :action=>:index
  end
  
  def invite_order
    tuan = ::Tuan.find(params[:id])
    limit = params[:limit].try(:to_i)||30
    invite_tuan_users = ::User.find_by_sql("select users.invite_tuan_user_id, count(users.invite_tuan_user_id) as invite_count from (order_items inner join orders on order_items.order_id=orders.id and order_items.item_id = #{tuan.id}) inner join users on users.id = orders.user_id and users.invite_tuan_user_id is not NULL group by users.invite_tuan_user_id order by invite_count desc")
    if invite_tuan_users.blank?
      @orders = TuanOrder.all(:select=>"orders.*,users.email,users.name",:conditions=>["order_items.item_id=? and orders.state in (?)",tuan.id,["has_paid","has_sent","has_sign_up","has_received","finished"]],:joins=>"inner join order_items on order_items.order_id=orders.id",:include=>[:user],:group=>"orders.user_id",:limit=>limit,:order=>"RAND()")
      @orders = @orders.inject([]) do |total_order,order|
        total_order << [order,0]
        total_order
      end
    else
      invite_tuan_user_ids = invite_tuan_users.collect{|invite| invite.invite_tuan_user_id}
      @orders = ::TuanOrder.all(:select=>"orders.*,users.email,users.name",:conditions=>["order_items.item_id=? and orders.user_id in (?) and orders.state in (?)",tuan.id,invite_tuan_user_ids.first(limit),["has_paid","has_sent","has_sign_up","has_received","finished"]],:joins=>"inner join order_items on order_items.order_id=orders.id",:include=>[:user],:group=>"orders.user_id")
      order_count = limit - @orders.count
      @orders += TuanOrder.all(:select=>"orders.*,users.email,users.name",:conditions=>["order_items.item_id=? and orders.user_id not in (?) and orders.state in (?)",tuan.id,invite_tuan_user_ids.first(limit),["has_paid","has_sent","has_sign_up","has_received","finished"]],:joins=>"inner join order_items on order_items.order_id=orders.id",:include=>[:user],:group=>"orders.user_id",:limit=>order_count,:order=>"RAND()") if order_count>0
      @orders = @orders.inject([]) do |total_order,order|
        total_order << [order,(invite_tuan_users.select{|invite_user| invite_user.invite_tuan_user_id==order.user_id}.collect{|invite_user| invite_user.invite_count}).first.try(:to_i)||0]
        total_order
        end.sort{|a,b|a[1]<=>b[1]}.reverse.first(limit)
      end
    end
    
    def address_action
      tuan = ::Tuan.find(params[:tuan_id])
      names = params[:names].split
      @orders = TuanOrder.all(:select=>"orders.*,users.email,users.name",:conditions=>["order_items.item_id=? and orders.receiver_name in (?)",tuan.id,names],:include=>[:user],:joins=>"inner join order_items on order_items.order_id=orders.id",:group=>"orders.receiver_name",:order=>"orders.created_at asc,orders.receiver_name asc")
    end
    
    def award
      tuan = ::Tuan.find(2191)
      @orders = TuanOrder.all(:select=>"orders.*,users.email,users.name",:conditions=>["order_items.item_id=? ",tuan.id],:joins=>"inner join order_items on order_items.order_id=orders.id",:include=>[:user],:group=>"orders.user_id",:order=>"users.email asc")
    end
    
    def old
      page = params[:page] || 1
      @tuans = ::Tuan.mms.ended(Time.now).paginate(:per_page => 20, :page => page, :include=>[:tuan_website],:order=>"created_at desc")
      render :action=>:index
    end
    
    def new
      @tuan = ::Tuan.new
      @tuan.address="全国"
      @tuan.free_fright_amount = 0
      @tuan.begin_time = Date.today
      @tuan.end_time = @tuan.begin_time
      @tuan.virtual = false
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @tuan }
      end
    end
    
    def create
      @tuan = ::Tuan.new(params[:tuan])
      @tuan.tp = 1
      @tuan.person_amount = 0
      respond_to do |format|
        if TuanWebsite.find_by_name("妈妈团").tuans << @tuan
          flash[:notice] = "#{@tuan.title} 创建成功"
          expire_fragment(:controller => "tuan", :action => "mama")
          expire_fragment(:controller => "tuan", :action => "mama_past")
          if @tuan.current_key
            Tuan.update_all("current_key = 0",["id <> ? and current_key=?",@tuan.id,true])
          end
          format.html { redirect_to :action=>:index }
          format.xml  { render :xml => @tuan, :status => :created, :location => @tuan }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @tuan.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    def edit
      @tuan = ::Tuan.find(params[:id])
    end
    
    def person_amount_edit
      @tuan = ::Tuan.find(params[:id])
    end
    
    def update
      @tuan = ::Tuan.find(params[:id])
      if params[:tuan][:supplier_code].present? and ::Supplier.last(:conditions=>["code=?",params[:tuan][:supplier_code]]).blank?
        @tuan.errors.add(:supplier_code,"供应商编码不正确")
        @suppliers = ::Supplier.all(:order=>"suppliers.code asc")
        render :action=>:supplier_code_edit and return
      end
      respond_to do |format|
        if @tuan.update_attributes(params[:tuan])
          if @tuan.current_key
            Tuan.update_all("current_key = 0",["id <> ? and current_key=?",@tuan.id,true])
          end
          flash[:notice] = "#{@tuan.short_content} 信息更新成功"
          format.html { redirect_to :action=>:index }
          format.xml  { head :ok }
        else
          format.html { render :action => :edit }
          format.xml  { render :xml => @tuan.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    def destroy
      @tuan = ::Tuan.find(params[:id])
      title = @tuan.title
      @tuan.destroy
      flash[:notice] = "#{title} 删除成功"
      respond_to do |format|
        format.html { redirect_to :action=>:index }
        format.xml  { head :ok }
      end
    end
    
    #########团购邮费设置############
    def cities
      @provinces = Province.all
      province_id = params[:id].blank? ? 1 : params[:id]
      @province = Province.find(province_id)
      @cities = City.all(:conditions=>["province_id=?",province_id],:order=>"name asc")
    end
    
    def city_edit
      @city = City.find(params[:id])    
    end
    
    def city_update
      @city=City.find(params[:id])
      
      respond_to do |format|
        if @city.update_attributes(params[:city])
          flash[:notice] = "#{@city.name} 邮费信息更新成功"
          format.html { redirect_to :action=>:cities,:id=>@city.province_id }
          format.xml  { head :ok }
        else
          format.html { render :action => :city_edit }
          format.xml  { render :xml => @city.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    def province
      @province = Province.find(params[:id])
    end
    
    def province_update
      fright_fee = params[:city][:fright_fee]
      City.update_all("fright_fee=#{fright_fee}",["province_id=?",params[:id]])
      flash[:notice] = "邮费信息更新成功"
      redirect_to :action=>:cities,:id=>params[:id]
    end
    
    def over_weight_index
      @fright_profiles = ::FrightProfile.all
    end
    
    def over_weight_new
      @fright_profile = ::FrightProfile.new
    end
    
    def over_weight_create
      @fright_profile = ::FrightProfile.new(params[:fright_profile])
      if @fright_profile.save
        redirect_to :action=>:over_weight
      else
        render :action=>:over_fright_new
      end
    end
    
    def over_weight_edit
      @fright_profile = ::FrightProfile.find(params[:id])
    end
    
    def over_weight_update
      @fright_profile = ::FrightProfile.find(params[:id])
      if @fright_profile.update_attributes(params[:fright_profile])
        flash[:notice] = "#{@fright_profile.name} 更新成功"
        redirect_to :action=>:over_weight_index
      else
        render :action=>:over_fright_new
      end
    end
    
    def over_weight_destroy
      @fright_profile = ::FrightProfile.find(params[:id])
      title = @fright_profile.name
      @fright_profile.destroy
      flash[:notice] = "#{title} 删除成功"
      respond_to do |format|
        format.html { redirect_to :action=>:over_weight_index }
        format.xml  { head :ok }
      end
    end
    
    def generate_email
      @tuan = ::Tuan.find(params[:id]) 
      render :action => :generate_email, :layout => false
    end
    
    def tuans_email
      @tuans = ::Tuan.all :conditions => ["id IN (?)", params[:tuan_ids].split(',')], :include => [:tuan_category], :order=>"tuans.tuan_category_id asc,tuans.begin_time desc"
      render :layout => false
    end
    
    #  ===========订单查看============
    
    def orders
      @tuan = ::Tuan.mms.find(params[:id])
      page = params[:page] || 1
      @cond = params[:cond] || ""
      conditions = [] 
      conditions << ["order_items.item_id=?",params[:id]]
      if @cond.blank?
        conditions << ['state IS NOT NULL']
      else
        conditions << ['state = ?', @cond]
      end
      @orders = TuanOrder.paginate :page =>page, :per_page =>30, :conditions =>  TuanOrder.merge_conditions(*conditions), :include=>[:user],:joins=>"inner join order_items on order_items.order_id=orders.id",:order=>"created_at desc"
    end
    
    def products
      @tuan = ::Tuan.mms.find(params[:id])
      page = params[:page]||1
      per_page = params[:per_page]||30
      @orders = TuanOrder.paginate :page =>page, :per_page =>per_page, :conditions => ["order_items.item_id=? and order_items.product_state is NULL and orders.state = ?",params[:id],"has_paid"],:include=>[:user], :joins=>"inner join order_items on order_items.order_id=orders.id",:order=>"created_at desc"
      #    @order_items = OrderItem.paginate :page =>page, :per_page =>per_page,:select=>"order_items.*,orders.*,users.id,users.email,users.name",:conditions => ["order_items.item_id=? and order_items.product_state is NULL and orders.state = ?",params[:id],"has_paid"], :joins=>"inner join orders on order_items.order_id=orders.id inner join users on orders.user_id=users.id",:order=>"order_items.created_at desc"
      #    @order_items= OrderItem.paginate (:page =>page, :per_page =>per_page,:joins=>{:order=>:user},:conditions=>{:order_items=>{:item_id=>params[:id],:product_state=>nil},:orders=>{:state=>"has_paid"}})
      #    @order_items= OrderItem.paginate (:page =>page, :per_page =>per_page,:include=>(:orders),:conditions=>{:order_items=>{:item_id=>params[:id],:product_state=>nil},:orders=>{:state=>"has_paid"}})
      
    end
    
    def send_product
      @tuan_id = params[:id].to_i
      @users = ::User.find(params[:user_ids].split(','),:select=>"users.id,users.name")
      @message_post = MessagePost.new
      @order_ids = params[:order_ids]
    end
    
    def send_product_action
      @tuan = ::Tuan.mms.find(params[:id])
      @tuan_id = params[:id].to_i
      @users = ::User.all(:select=>"users.id,users.name,users.email",:conditions=>["users.name in (?)",params[:user_names].split("\;")])
      emails = @users.map(&:email)
      @users.each do |user|
        params[:message_post][:user_name] = user.name
        @message_post = MessagePost.create_message_post(params,::User.find(User.mms_user_id))
        unless @message_post.errors.empty?
          render :action=>'send_product' and return false
        end
      end
      ::TuanOrder.update_all("state='has_sent'",["id in (?)",params[:order_ids].split(',')])
      
      flash[:notice]="发送成功"
      redirect_to :action=>:index
    end
    
    ########虚拟商品开始########
    def virtual_index
      @tuan = Tuan.mms.find(params[:id])
      @products = @tuan.virtual_products
      redirect_to :action=>:virtual_new,:id=>@tuan.id and return if @products.blank?
    end
    
    def virtual_new
      @tuan = Tuan.mms.find(params[:id])
      @product = @tuan.virtual_products.last
      if @product.blank?
        @product = VirtualProduct.new
        @product.person_amount = 1
        @product.limit_time = 7
        @product.tuan_id = @tuan.id
      end
    end
    
    def virtual_create
      @tuan = ::Tuan.mms.find(params[:id])
      person_amount = params[:virtual_product][:person_amount].to_i
      if person_amount == 1
        clazz = "SingleVirtualProduct"
      elsif person_amount > 1
        clazz = "MultiVirtualProduct"
      elsif person_amount == 0
        clazz = "UnlimitedVirtualProduct"
      end
      
      @virtual_product = eval(clazz).new(params[:virtual_product])
      if @virtual_product.tp == 0
        @codes = params[:codes]
        @codes.split.each do |code|
          obj = @virtual_product.clone
          code_password = code.split('|')
          obj.code = code_password[0]
          obj.password = code_password[1]
          obj.save
        end
      else
        @virtual_product.save
      end
      flash[:notice] = "操作成功"
      redirect_to :action=>:virtual_index,:id=>@tuan.id
    end
    
    def virtual_edit
      @product = ::VirtualProduct.find(params[:id])
    end
    
    def virtual_update
      @product = ::VirtualProduct.find(params[:id])
      if @product.update_attributes(params[:virtual_product])
        flash[:notice] = "#{@product.code} 更新成功"
        redirect_to :action=>:virtual_index,:id=>@product.tuan_id
      else
        render :action=>:virtual_edit,:id=>@product.id
      end
    end
    
    def virtual_show
      @product = ::VirtualProduct.find(params[:id])
      render :layout=>false
    end
    
    def virtual_destroy
      @product = ::VirtualProduct.find(params[:id])
      tuan_id = @product.tuan_id
      @product.destroy
      flash[:notice] = "删除成功"
      respond_to do |format|
        format.html { redirect_to :action=>:virtual_index,:id=>tuan_id }
        format.xml  { head :ok }
      end
    end
    
    def virtual_edit_all
      @tuan = ::Tuan.mms.find(params[:id])
      @product = @tuan.virtual_products.last
    end
    
    def virtual_update_all
      @tuan = ::Tuan.mms.find(params[:id])
      ::VirtualProduct.update_all(params[:virtual_product],["tuan_id=?",@tuan.id])
      flash[:notice] = "操作成功"
      redirect_to :action=>:virtual_index,:id=>@tuan.id
    end
    
    def virtual_log_index
      @tuan = Tuan.mms.find(params[:id])
      @logs = VirtualProductLog.paginate :conditions=>["order_items.item_id=?",params[:id]],:joins=>"inner join order_items on order_items.id=virtual_product_logs.order_item_id",:page =>params[:page]||1, :per_page =>params[:per_page]||25
      redirect_to :action=>:virtual_index,:id=>@tuan.id and return if @logs.blank?
    end
    
    def virtual_log_show
      @quan = VirtualProductLog.first(:conditions=>["virtual_product_logs.id=?",params[:id]],:include=>[:virtual_product]) rescue nil
      return render_404 if @quan.blank?
      @product = @quan.virtual_product
      @order = @quan.order_item.order
      render "/tuan/quan",:layout=>false
    end
    
    ########虚拟商品结束########
    
    def supplier_code_edit
      @suppliers = ::Supplier.all(:order=>"suppliers.code asc")
      @tuan = ::Tuan.find(params[:id])
    end
    
  end
