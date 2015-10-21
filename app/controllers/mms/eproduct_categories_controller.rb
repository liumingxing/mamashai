class Mms::EproductCategoriesController < Mms::MmsBackEndController
  
  def index
    page = params[:page] || 1
    if params[:level]=='0'
      @categories = ::EproductCategory.roots.paginate(:per_page => 20, :page => page,:order=>"eproduct_categories.created_at desc")
    else
      @categories = ::EproductCategory.paginate(:per_page => 20, :page => page,:order=>"eproduct_categories.created_at desc")
    end
  
  end
    
  def search
    page = params[:page] || 1
    @keyword = params[:keyword]
    @categories = ::EproductCategory.paginate(:per_page => 20, :page => page, :conditions=>["name like ?","%"+params[:keyword]+"%"], :order => "eproduct_categories.created_at desc")
    render :action=>:index
  end
  
  def new
    @category = ::EproductCategory.new
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @category }
    end
  end
  
  def create
    @category = ::EproductCategory.new(params[:eproduct_category])
    respond_to do |format|
      if @category.save
        flash[:notice] = "#{@category.name} 创建成功"
        format.html { redirect_to :action=>:index }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @category = ::EproductCategory.find(params[:id])
  end
  
  def update
    @category = ::EproductCategory.find(params[:id]) 
    respond_to do |format|
      if @category.update_attributes(params[:eproduct_category])
        flash[:notice] = "#{@category.name} 信息更新成功"
        format.html { redirect_to :action=>:index }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @category = ::EproductCategory.find(params[:id])
    name = @category.name
    @category.destroy
    flash[:notice] = "#{name} 删除成功"
    respond_to do |format|
      format.html { redirect_to :action=>:index }
      format.xml  { head :ok }
    end
  end
  
  
  
end
