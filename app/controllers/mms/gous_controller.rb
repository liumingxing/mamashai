require 'fileutils'
require "awesome_nested_set"
require 'rubygems'
require 'nokogiri'
require 'open-uri'
class Mms::GousController < Mms::MmsBackEndController
  uses_tiny_mce(:options => Article.tiny_advance_options,:only => [:edit, :new])
  
  def index
    conditions = ["1=1"]
    conditions << "tp='#{params[:tp]}'" if params[:tp]
    @gous = ::Gou.paginate(:per_page => 35, :page => params[:page], :order => 'gous.created_at desc', :conditions=>conditions.join(" and "))
  end
  
  def new
    @gou = ::Gou.new
    user = Mms::User.find_user(@mms_user)
    @gou.user_id = user.id if user
    @gou.tp = params[:tp]
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @gou }
    end
  end
  
  def create
    @gou = ::Gou.new(params[:gou])
    
    respond_to do |format|
      if @gou.save
        flash[:notice] = "#{@gou.name} 创建成功"
        format.html { redirect_to :action=>:index, :tp=>params[:gou][:tp] }
        format.xml  { render :xml => @gou, :status => :created, :location => @gou }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @gou.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @gou = ::Gou.find(params[:id])
  end
  
  def update
    @gou = ::Gou.find(params[:id]) 
#    @gou.disable_ferret
    respond_to do |format|
      if @gou.update_attributes(params[:gou])
        flash[:notice] = "#{@gou.name} 信息更新成功"
        format.html { redirect_to :action=>:index }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @gou.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @gou = ::Gou.find(params[:id])
    name = @gou.name
    @gou.destroy
    flash[:notice] = "#{name} 删除成功"
    respond_to do |format|
      format.html { redirect_to :action=>:index }
      format.xml  { head :ok }
    end
  end
  
  def search
    page = params[:page] || 1
    @keyword = params[:keyword]
    @gous = ::Gou.paginate(:per_page => 35, :page => page, :conditions=>["gous.name like ?","%"+params[:keyword]+"%"], :order => "gous.created_at desc")
    render :action=>:index
  end
  
  def gou_unpublish
    gou = ::Gou.find(params[:id])
    gou.fire_events(:unpublish)
    redirect_to :action => :index
  end
  
  def gou_publish
    gou = ::Gou.find(params[:id])
    gou.fire_events(:publish)
    redirect_to :action => :index
  end
  
  def category_index
    @root = ::GouCategory.find(params[:id]) if params[:id].present?
    @root = ::GouCategory.first if params[:id].blank?
  end
  
  def category_search
    page = params[:page] || 1
    @keyword = params[:keyword]
    @categories = ::GouCategory.paginate(:per_page => 45, :page => page, :conditions=>["name like ?","%"+params[:keyword]+"%"], :order => "gou_categories.created_at desc")
  end
  
  def category_new
    @category = ::GouCategory.new
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @category }
    end
  end
  
  def category_create
    @category = ::GouCategory.new(params[:gou_category])
    respond_to do |format|
      if @category.save
        flash[:notice] = "#{@category.name} 创建成功"
        format.html { redirect_to :action=>:category_index }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "category_new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def category_edit
    @category = ::GouCategory.find(params[:id])
  end
  
  def category_update
    @category = ::GouCategory.find(params[:id]) 
    respond_to do |format|
      if @category.update_attributes(params[:gou_category])
        flash[:notice] = "#{@category.name} 信息更新成功"
        format.html { redirect_to :action=>:category_index }
        format.xml  { head :ok }
      else
        format.html { render :action => :category_edit }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def category_destroy
    @category = ::GouCategory.find(params[:id])
    name = @category.name
    @category.destroy
    flash[:notice] = "#{name} 删除成功"
    respond_to do |format|
      format.html { redirect_to :action=>:category_index }
      format.xml  { head :ok }
    end
  end
  
  def category_unpublish
    category = ::GouCategory.find(params[:id])
    category.fire_events(:unpublish)
    redirect_to :action => :category_index
  end
  
  def category_publish
    category = ::GouCategory.find(params[:id])
    category.fire_events(:publish)
    redirect_to :action => :category_index
  end
  
  def brand_index
    page = params[:page] || 1
    @brands = ::GouBrand.paginate(:per_page => 35, :page => page, :order => 'gou_brands.created_at desc', :include => [:article])
  end
  
  def brand_search
    page = params[:page] || 1
    @keyword = params[:keyword]
    @brands = ::GouBrand.paginate(:per_page => 35, :page => page, :conditions=>["name like ?","%"+params[:keyword]+"%"], :order => "gou_brands.created_at desc", :include => [:article])
    render :action=>:brand_index
  end
  
  def brand_new
    @brand = ::GouBrand.new()
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @brand }
    end
  end
  
  def brand_create
    @brand = ::GouBrand.new(params[:gou_brand])
    subject = ::Subject.new(:name=>(@brand.name+"粉丝群"),:content=>"这里是"+@brand.name+"粉丝群。",:user_id=>::User.mms_user_id)
    subject.banner = params[:gou_brand][:banner]
    subject.logo = params[:gou_brand][:logo]
    @brand.subject = subject
    if subject.save(:validate=>false)
      su = SubjectUser.new(:user_id=>::User.mms_user_id)
      su.subject = subject
      su.save
      @brand.save
    end

    respond_to do |format|
      if @brand.save
        flash[:notice] = "#{@brand.name} 创建成功"
        format.html { redirect_to :action=>:brand_index }
        format.xml  { render :xml => @brand, :status => :created, :location => @brand }
      else
        format.html { render :action => "brand_new" }
        format.xml  { render :xml => @brand.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def brand_edit
    @brand = ::GouBrand.find(params[:id])
  end
  
  def brand_update
    @brand = ::GouBrand.find(params[:id]) 
    respond_to do |format|
      if @brand.update_attributes(params[:gou_brand])
        flash[:notice] = "#{@brand.name} 信息更新成功"
        format.html { redirect_to :action=>:brand_index }
        format.xml  { head :ok }
      else
        format.html { render :action => :brand_edit }
        format.xml  { render :xml => @brand.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def brand_destroy
    @brand = ::GouBrand.find(params[:id])
    name = @brand.name
    @brand.destroy
    flash[:notice] = "#{name} 删除成功"
    respond_to do |format|
      format.html { redirect_to :action=>:brand_index }
      format.xml  { head :ok }
    end
  end
  
  def brand_unpublish
    brand = ::GouBrand.find(params[:id])
    brand.fire_events(:unpublish)
    redirect_to :action => :brand_index
  end
  
  def brand_publish
    brand = ::GouBrand.find(params[:id])
    brand.fire_events(:publish)
    redirect_to :action => :brand_index
  end
  
  def articles
    @brand = ::GouBrand.find(params[:brand_id])
    page = (params[:page] unless params[:page].blank?) || 1
    @article = @brand.article if @brand.article.present?
    @articles = ::Article.paginate(:per_page => 20, :page => page, :include => [:article_category, :article_brand], :order => "articles.created_at DESC", :conditions => ['articles.gou_brand_article_id = ?', @brand.id])
  end
  
  def article_search
    @brand = ::GouBrand.find(params[:brand_id])
    @keyword = params[:keyword]
    page = (params[:page] unless params[:page].blank?) || 1
    @articles = ::Article.paginate(:per_page => 20, :page => page, :include => [:article_category, :article_brand], :order => "articles.created_at DESC", :conditions => ['articles.gou_brand_article_id = ? and articles.title LIKE ?', @brand.id, "%#{params[:keyword]}%"])
    render :action => :articles, :brand_id => @brand.id
  end
  
  def article_new
    @type = params[:type]
    @title = "品牌资讯" and @categories = ::ArticleCategory.gou_brand_article.all.map{|t| [t.name, t.id]} if @type == "article"
    @title = "品牌故事" and @categories = ::ArticleCategory.gou_brand_story.all.map{|t| [t.name, t.id]} if @type == "story"
    @brand = ::GouBrand.find(params[:brand_id])
    @article = Article.new
  end
  
  def article_create
    @title = params[:title]
    if params[:article_content][:content].blank?
      flash[:notice] = "#{@title}内容不能为空！"
      redirect_to :back
    else
      ::Article.transaction do
        @article = ::Article.create(params[:article])
        @article.state = '已发布'
        if @article.errors.blank?
          ::ArticleContent.create(:content => params[:article_content][:content], :article_id => @article.id) 
          user = ::User.find_by_name(@article.author)
          if user
            @article.user_id = user.id
            @article.save
          end
        end
      end
      if @article.errors.blank?
        flash[:notice] = "新建#{@title}成功！"
        redirect_to :action => :articles, :brand_id => @article.gou_brand_article_id if @article.gou_brand_article_id.present?
        redirect_to :action => :articles, :brand_id => @article.gou_brand_story_id if @article.gou_brand_story_id.present?
      else
        flash[:notice] = "新建#{@title}失败！"
        redirect_to :back
      end
    end
  end
  
  def article_edit
    @article = ::Article.find(params[:id], :include => "article_content")
    @title = "品牌资讯" and @categories = ::ArticleCategory.gou_brand_article.all.map{|t| [t.name, t.id]} if @article.gou_brand_article_id.present?
    @title = "品牌故事" and @categories = ::ArticleCategory.gou_brand_story.all.map{|t| [t.name, t.id]} if @article.gou_brand_story_id.present?
    @article_content = @article.article_content
  end
  
  def article_update
    @title = params[:title]
    if params[:article_content][:content].blank?
      flash[:notice] = "#{@title}内容不能为空！"
      redirect_to :back
    else
      @article = Article.find(params[:id])
      ::Article.transaction do
        @article.update_attributes(params[:article])
        if @article.errors.blank?
          @article.article_content.update_attribute(:content, params[:article_content][:content]) 
          user = ::User.find_by_name(@article.author)
          @article.user_id = nil
          if user
            @article.user_id = user.id
          end
          @article.save
        end
      end
      if @article.errors.blank?
        flash[:notice] = "修改#{@title}成功！"
        redirect_to :action => :articles, :brand_id => @article.gou_brand_article_id if @article.gou_brand_article_id.present?
        redirect_to :action => :articles, :brand_id => @article.gou_brand_story_id if @article.gou_brand_story_id.present?
      else
        flash[:notice] = "修改#{@title}失败！"
        redirect_to :back
      end
    end
  end
  
  def article_destroy
    @article = ::Article.find(params[:id])
    @title = "品牌资讯" if @article.gou_brand_article_id.present?
    @title = "品牌故事" if @article.gou_brand_story_id.present?
    flash[:notice] = "删除#{@title}成功！"
    flash[:notice] = "删除#{@title}失败！" unless @article.destroy
    redirect_to :action => :articles, :brand_id => @article.gou_brand_article_id if @article.gou_brand_article_id.present?
    redirect_to :action => :articles, :brand_id => @article.gou_brand_story_id if @article.gou_brand_story_id.present?
  end
  
  def publish
    article = ::Article.find(params[:id])
    @title = "品牌资讯" if article.gou_brand_article_id.present?
    @title = "品牌故事" if article.gou_brand_story_id.present?
    flash[:notice] = "修改#{@title}发布状态成功！"
    flash[:notice] = "修改#{@title}发布状态失败！" if !article.update_attribute(:state, "已发布")
    redirect_to :action => :articles, :brand_id => article.gou_brand_article_id if article.gou_brand_article_id.present?
    redirect_to :action => :articles, :brand_id => article.gou_brand_story_id if article.gou_brand_story_id.present?
  end
  
  def unpublish
    article = ::Article.find(params[:id])
    flash[:notice] = "修改资讯发布状态成功！"
    flash[:notice] = "修改资讯发布状态失败！" if !article.update_attribute(:state, "未发布")
    redirect_to :action => :articles, :brand_id => article.gou_brand_article_id if article.gou_brand_article_id.present?
    redirect_to :action => :articles, :brand_id => article.gou_brand_story_id if article.gou_brand_story_id.present?
  end
  
  def site_index
    page = params[:page] || 1
    @sites = ::GouSite.paginate(:per_page => 35, :page => page, :order => 'gou_sites.created_at desc')
  end
  
  def site_search
    page = params[:page] || 1
    @keyword = params[:keyword]
    @sites = ::GouSite.paginate(:per_page => 35, :page => page, :conditions=>["name like ?","%"+params[:keyword]+"%"], :order => "gou_sites.created_at desc")
    render :action=>:site_index
  end
  
  def site_new
    @site = ::GouSite.new()
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @site }
    end
  end
  
  def site_create
    @site = ::GouSite.new(params[:gou_site])
    respond_to do |format|
      if @site.save
        flash[:notice] = "#{@site.name} 创建成功"
        format.html { redirect_to :action=>:site_index }
        format.xml  { render :xml => @site, :status => :created, :location => @site }
      else
        format.html { render :action => "site_new" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def site_edit
    @site = ::GouSite.find(params[:id])
  end
  
  def site_update
    @site = ::GouSite.find(params[:id]) 
    respond_to do |format|
      if @site.update_attributes(params[:gou_site])
        flash[:notice] = "#{@site.name} 信息更新成功"
        format.html { redirect_to :action=>:site_index }
        format.xml  { head :ok }
      else
        format.html { render :action => :site_edit }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def site_destroy
    @site = ::GouSite.find(params[:id])
    name = @site.name
    @site.destroy
    flash[:notice] = "#{name} 删除成功"
    respond_to do |format|
      format.html { redirect_to :action=>:site_index }
      format.xml  { head :ok }
    end
  end
  
  def site_unpublish
    site = ::GouSite.find(params[:id])
    site.fire_events(:unpublish)
    redirect_to :action => :site_index
  end
  
  def site_publish
    site = ::GouSite.find(params[:id])
    site.fire_events(:publish)
    redirect_to :action => :site_index
  end
  
  def site_logs
    #暂时只有1个-红孩子
    @logs = GouSiteLog.paginate :page=>params[:page]||1,:per_page=>30,:order=>"gou_site_logs.created_at desc"
  end
  
  def catch
    
  end
  
  def catch_xml
    @site_id = params[:site][:id]
    @site_catch_time = params[:site][:catch_time]
    @category_name = params[:category_name] if params[:category_name].present?
    doc = GouSite.generate_html(@site_id, @site_catch_time)
    @site_name = doc.at_xpath("//Name").text.to_s
    @gous = doc.xpath("//ProductInfo")
  end
  
  def create_gou
    flash[:notice] = '暂无抓取商品！' if params[:gou].blank? or params[:gou][:check].blank?
    redirect_to :action => :index and return unless flash[:notice].blank?
    params[:gou][:check].each do |key, value|
      if value.to_i == 1
        first_category = GouCategory.first(:conditions => ['gou_categories.name = ?', params[:gou][:first_category][key]])
        first_category.update_attributes(:name => params[:gou][:first_category][key]) if first_category.present?
        first_category = GouCategory.create(:name => params[:gou][:first_category][key]) if first_category.blank?
        next if first_category.blank?
        second_category = GouCategory.first(:conditions => ['gou_categories.name = ?', params[:gou][:second_category][key]])
        second_category.update_attributes(:name => params[:gou][:second_category][key], :parent_id => first_category.id) if second_category.present?
        second_category = GouCategory.create(:name => params[:gou][:second_category][key], :parent_id => first_category.id) if second_category.blank?
        next if second_category.blank?
        third_category = GouCategory.first(:conditions => ['gou_categories.name = ?', params[:gou][:third_category][key]])
        third_category.update_attributes(:name => params[:gou][:third_category][key], :parent_id => second_category.id) if third_category.present?
        third_category = GouCategory.create(:name => params[:gou][:third_category][key], :parent_id => second_category.id) if third_category.blank?
        next if third_category.blank?
        category = GouCategory.find(params[:gou][:category])
        brand = GouBrand.first(:conditions => ['gou_brands.name = ?', params[:gou][:brand][key]])
        brand.update_attributes(:name => params[:gou][:brand][key]) if brand.present?
        brand = GouBrand.create(:name => params[:gou][:brand][key]) if brand.blank?
        next if brand.blank?
        gou = Gou.first(:conditions => ['gous.link = ?', params[:gou][:link][key]])
        gou.update_attributes(:name => params[:gou][:name][key], :price => params[:gou][:price][key], :content => params[:gou][:content][key], :standard => params[:gou][:standard][key], :link => params[:gou][:link][key], :gou_category_id => category.id, :site_name =>  params[:gou][:site_name][key], :gou_brand_id => brand.id, :logo => (File.open(params[:gou][:logo][key]) if File.exist?(params[:gou][:logo][key])) || nil) if gou.present?
        gou = Gou.create(:name => params[:gou][:name][key], :price => params[:gou][:price][key], :content => params[:gou][:content][key], :standard => params[:gou][:standard][key], :link => params[:gou][:link][key], :gou_category_id => category.id, :site_name =>  params[:gou][:site_name][key], :gou_brand_id => brand.id, :logo => (File.open(params[:gou][:logo][key]) if File.exist?(params[:gou][:logo][key])) || nil) if gou.blank?
      end
    end
    redirect_to :action => :index and return if flash[:notice].blank?
  end
  
  def comments
    page = (params[:page] unless params[:page].blank?) || 1
    @comments = ::TuanComment.paginate(:per_page => 30, :page => page, :conditions => ['tuan_comments.gou_id IS NOT NULL'], :include => [:gou, :user])
  end
  
  def comment_edit
    @comment = ::TuanComment.find(params[:id])
  end
  
  def update_comment
    @comment = ::TuanComment.find(params[:id])
    if @comment.update_attributes(params[:comment])
      flash[:notice] = "修改成功！"
      redirect_to :action => :comments
    else
      flash[:notice] = "修改失败！"
      render :action => "comment_edit", :id => @comment.id
    end
  end
  
  def comment_destroy
    @comment = ::TuanComment.find(params[:id])
    flash[:notice] = "删除失败！"
    flash[:notice] = "删除成功！" if @comment.destroy
    redirect_to :action => :comments
  end
  
  def comment_search
    cond = []
    cond = ['tuan_comments.gou_id IS NOT NULL']
    page = (params[:page] unless params[:page].blank?) || 1
    @keyword = params[:keyword]
    gou_ids = ::Gou.all(:conditions => ['gous.name like ?', "%#{@keyword}%"], :select => 'id').map(&:id)
    cond << ['tuan_comments.content like ? or tuan_comments.gou_id in (?)', "%#{@keyword}%", gou_ids]
    @comments = ::TuanComment.paginate(:per_page => 30, :page => page, :conditions => ::TuanComment.merge_conditions(*cond), :include => [:gou, :user])
    render :action => :comments
  end
  
  def mfn
    @profile = ::NaProfile.find_by_gou_id(params[:id])
    @profile = ::NaProfile.new(:gou_id=>params[:id]) if !@profile
  end
  
  def sort_na
    @profiles = NaProfile.find(:all)
  end
  
  def create_mfn_profile
    @profile = ::NaProfile.find_by_gou_id(params[:na_profile][:gou_id])
    if @profile
      @profile.update_attributes(params[:na_profile])
    else    
      @profile = ::NaProfile.new(params[:na_profile]) if !@profile
      @profile.save
    end
    if @profile.errors.size > 0
      render :action=>"mfn"
    else
      flash[:notice] = "设置成功"
      redirect_to :action=>"index", :tp=>"na"
    end
  end
end
