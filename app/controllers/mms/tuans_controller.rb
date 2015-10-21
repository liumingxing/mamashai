class Mms::TuansController < Mms::MmsBackEndController
  
  def index
    page = params[:page] || 1
    @tuans = ::Tuan.others_tuan.paginate(:conditions=>["end_time >= ?",Time.now], :per_page => 20, :page => page, :include=>[:tuan_website],:order=>"tuans.created_at desc")
  end
    
  def search
    page = params[:page] || 1
    @tuans = ::Tuan.others_tuan.paginate(:per_page => 20, :page => page, :conditions=>["(content like ?)","%"+params[:keyword]+"%"], :include => [:tuan_website], :order => "tuans.created_at DESC")
    render :action=>:index
  end
  
  def old
    page = params[:page] || 1
    @tuans = ::Tuan.others_tuan.paginate(:conditions=>["end_time < ?",Time.now], :per_page => 20, :page => page, :include=>[:tuan_website],:order=>"tuans.created_at desc")
    render :action=>:index
  end
  
  def new
    @tuan = ::Tuan.new
    @tuan.address = '北京'
    if params[:url].present?
      @tuan.url = params[:url]
      website = TuanWebsite.first(:conditions=>['catch_url is not null and url like ?',"%"+params[:url].gsub(/http:\/\/(.+?)\/(.+?)$/,'\\1')+"%"])
      @tuan = website.load_tuan_from_xml(@tuan) if website 
    end
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @tuan }
    end
  end
  
  def create
    @tuan = ::Tuan.new(params[:tuan])
    @tuan.tp = 0
    respond_to do |format|
      if @tuan.save
        mama = TuanMama.new
        mama.tuan_id = @tuan.id
        mama.save
        flash[:notice] = "#{@tuan.title} 创建成功"
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
  
  def update
    @tuan = ::Tuan.find(params[:id]) 
    respond_to do |format|
      if @tuan.update_attributes(params[:tuan])
        flash[:notice] = "#{@tuan.title} 信息更新成功"
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
  
  
  #==========团购导航分类管理================
  def category_index
    page = params[:page] || 1
    @tuan_categories = ::TuanCategory.paginate(:per_page => 20, :page => page,:order=>"id asc")
  end
  
  def category_new
    @tuan_category = ::TuanCategory.new
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @tuan_category }
    end
  end
  
  def category_create
    @tuan_category = ::TuanCategory.new(params[:tuan_category])
    respond_to do |format|
      if @tuan_category.save
        flash[:notice] = "#{@tuan_category.name} 创建成功"
        format.html { redirect_to :action=>:category_index }
        format.xml  { render :xml => @tuan_category, :status => :created, :location => @tuan_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tuan_category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def category_edit
    @tuan_category = ::TuanCategory.find(params[:id])
  end
  
  def category_update
    @tuan_category = ::TuanCategory.find(params[:id])
    
    respond_to do |format|
      if @tuan_category.update_attributes(params[:tuan_category])
        flash[:notice] = "#{@tuan_category.name} 信息更新成功"
        format.html { redirect_to :action=>:category_index }
        format.xml  { head :ok }
      else
        format.html { render :action => :category_edit }
        format.xml  { render :xml => @tuan_category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def category_destroy
    @tuan_category = ::TuanCategory.find(params[:id])
    name = @tuan_category.name
    @tuan_category.destroy
    flash[:notice] = "#{name} 删除成功"
    respond_to do |format|
      format.html { redirect_to :action=>:category_index }
      format.xml  { head :ok }
    end
  end
  
  #==========团购导航-网站管理================
  def website_index
    page = params[:page] || 1
    @tuan_websites = ::TuanWebsite.paginate(:per_page => 20, :page => page,:order=>"created_at desc")
  end
  
  def website_search
    page = params[:page] || 1
    keyword = "%"+params[:keyword]+"%"
    @tuan_websites = ::TuanWebsite.paginate(:per_page => 20, :page => page,:order=>"created_at desc", :conditions => ["name like ? or url like ? or open_at like ?", keyword, keyword, keyword])
    render :action => :website_index
  end
  
  def website_new
    @tuan_website = ::TuanWebsite.new
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @tuan_website }
    end
  end
  
  def website_create
    @tuan_website = ::TuanWebsite.new(params[:tuan_website])
    respond_to do |format|
      if @tuan_website.save
        flash[:notice] = "#{@tuan_website.name} 创建成功"
        format.html { redirect_to :action=>:website_index }
        format.xml  { render :xml => @tuan_website, :status => :created, :location => @tuan_website }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tuan_website.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def website_edit
    @tuan_website = ::TuanWebsite.find(params[:id])
  end
  
  def website_update
    @tuan_website = ::TuanWebsite.find(params[:id])
    
    respond_to do |format|
      if @tuan_website.update_attributes(params[:tuan_website])
        flash[:notice] = "#{@tuan_website.name} 信息更新成功"
        format.html { redirect_to :action=>:website_index }
        format.xml  { head :ok }
      else
        format.html { render :action => :website_edit }
        format.xml  { render :xml => @tuan_website.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def website_destroy
    @tuan_website = ::TuanWebsite.find(params[:id])
    name = @tuan_website.name
    @tuan_website.destroy
    flash[:notice] = "#{name} 删除成功"
    respond_to do |format|
      format.html { redirect_to :action=>:website_index }
      format.xml  { head :ok }
    end
  end
  
  def catch
    @tuan_website = ::TuanWebsite.find(params[:id])
  end
  
  def set_catch_config
    @tuan_website = ::TuanWebsite.find(params[:id])
    @configures = ::TuanWebsite.configures
    @website_configures = @tuan_website.try(:catch_config)
    @website_configures = {'content'=>'title','content'=>'title','begin_time'=>'startTime','end_time'=>'endTime','origin_price'=>'value','current_price'=>'price','person_amount'=>'bought'} if @website_configures.blank?
  end
  
  def set_catch_config_action
    @tuan_website = ::TuanWebsite.find(params[:id])
    @tuan_website.update_attributes(:catch_url=>params[:tuan_website][:catch_url],:catch_config=>params[:config])
    redirect_to :action=>:website_index
  end
  
  def test_catch
    tuan_website = ::TuanWebsite.find(params[:id]) 
    render :text=>"共#{tuan_website.catch.length}个团购信息"
  end
  
  def clear_catch
    @tuan_website = ::TuanWebsite.find(params[:id])
    @tuan_website.update_attributes(:catch_config => nil,:catch_url=>nil)
    redirect_to :action=>:website_index
  end
  
  
  #================发布抓取到的团购信息================
  def temp_index
    page = params[:page] || 1
    @tuans = ::TuanTemp.paginate(:conditions=>["passed=?",false], :per_page => 20, :page => page, :include=>[:tuan_website],:order=>"tuan_temps.created_at desc")
  end
  
  def temp_show
    @tuan = ::TuanTemp.find(params[:id])
    render :layout=>"tuan"
  end
  
  def temp_destroy
    @tuan = ::TuanTemp.find(params[:id])
    content = @tuan.content
    @tuan.destroy
    flash[:notice] = "#{content} 删除成功"
    respond_to do |format|
      format.html { redirect_to :action=>:temp_index }
      format.xml  { head :ok }
    end
  end
  
  def temp_publish
    @tuan = ::TuanTemp.find(params[:temp_tuan_id])
    content =@tuan.content
    if @tuan.change_to_tuan(params[:tuan])
      @tuan.destroy 
      flash[:notice]="#{content} 发布成功"
    else
      flash[:notice]="信息不完整，发布失败"
    end
    respond_to do |format|
      format.html { redirect_to :action=>:temp_index }
      format.xml  { head :ok }
    end
  end
  
  def temp_edit
    @tuan = ::TuanTemp.find(params[:id])
  end
  
  def temp_update
    @tuan = ::TuanTemp.find(params[:id])
    respond_to do |format|
      if @tuan.update_attributes(params[:tuan_temp])
        flash[:notice] = "#{@tuan.content} 信息更新成功"
        format.html { redirect_to :action=>:temp_index }
        format.xml  { head :ok }
      else
        format.html { render :action => :temp_edit }
        format.xml  { render :xml => @tuan.errors, :status => :unprocessable_entity }
      end
    end
  end
  #==========妈妈晒团购信息管理================
  
  def mms_tuan
    page = params[:page] || 1
    @tuans = ::Tuan.mms.paginate(:conditions=>["end_time >= ?",Time.now], :per_page => 20, :page => page, :include=>[:tuan_website],:order=>"tuans.created_at desc")
  end
  
  #############团购导航临时分类#################
  
  def category_temp_index
    page = params[:page] || 1
    @tuan_categories = ::TuanCategoryTemp.paginate(:per_page => 20, :page => page, :include=>[:tuan_category],:order=>"tuan_category_temps.id asc")
  end
  
  def category_temp_update
    @tuan_category = ::TuanCategoryTemp.find(params[:id])
    respond_to do |format|
      if @tuan_category.update_attributes(params[:tuan_category_temp])
        tuan_category_id = params[:tuan_category_temp][:tuan_category_id].to_i
        ::Tuan.update_all("tuan_category_id = #{tuan_category_id} , tuan_category_temp_id = null, tp=0","tuan_category_temp_id=#{@tuan_category.id}")
#        ::TuanCategoryTemp.reset_counters(@tuan_category.id, :tuans)
        ::TuanCategoryTemp.update_all("tuans_count=0",["id = ?",@tuan_category.id])
        count = Tuan.count(:all,:conditions=>["tuan_category_id = ?",tuan_category_id])
        ::TuanCategory.update_all("tuans_count = #{count}",["id = ?",tuan_category_id])
        
        flash[:notice] = "#{@tuan_category.name} 信息更新成功"
        format.html { redirect_to :action=>:category_temp_index }
        format.xml  { head :ok }
      else
        format.html { render :action => :category_temp_edit }
        format.xml  { render :xml => @tuan_category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def category_temp_destroy
    @tuan_category = ::TuanCategoryTemp.find(params[:id])
    name = @tuan_category.name
    @tuan_category.destroy
    flash[:notice] = "#{name} 删除成功"
    respond_to do |format|
      format.html { redirect_to :action=>:category_temp_index }
      format.xml  { head :ok }
    end
  end
  
  # ============ 留言管理 ============
  
  def tuan_message
    page = params[:page] || 1
    @messages = ::TuanMessage.paginate :per_page => 20, :page => page, :order => "created_at DESC"    
  end
  
  def message_delete
    ::TuanMessage.find(params[:id]).destroy
    redirect_to :action => "tuan_message"
  end
  
  def message_search
    @keyword = params[:keyword] || ""
    user = ::User.first :conditions => ["name LIKE ?", @keyword]
    user_id = (user.id unless user.blank?) || ""
    page = params[:page] || 1
    @messages = ::TuanMessage.paginate :per_page => 20, :page => page, :conditions => ['content LIKE ? OR user_id = ? OR created_at LIKE ?', "%#{@keyword}%", user_id, "%#{@keyword}%"], :order => "created_at DESC"
    render :action => "tuan_message"
  end
  
end
