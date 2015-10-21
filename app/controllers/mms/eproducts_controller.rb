class Mms::EproductsController < Mms::MmsBackEndController
  
  def index
    page = params[:page] || 1
    @eproducts = ::Eproduct.paginate(:per_page => 20, :page => page,:order=>"eproducts.created_at desc")
  end
    
  def search
    page = params[:page] || 1
    @keyword = params[:keyword]
    @eproducts = ::Eproduct.paginate(:per_page => 20, :page => page, :conditions=>["name like ?","%"+params[:keyword]+"%"], :order => "eproducts.created_at desc")
    render :action=>:index
  end
  
  def new
    @eproduct = ::Eproduct.new
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @eproduct }
    end
  end
  
  def create
    @eproduct = ::Eproduct.new(params[:eproduct])
    respond_to do |format|
      if @eproduct.save
        flash[:notice] = "#{@eproduct.name} 创建成功"
        format.html { redirect_to :action=>:index }
        format.xml  { render :xml => @eproduct, :status => :created, :location => @eproduct }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @eproduct.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @eproduct = ::Eproduct.find(params[:id])
  end
  
  def update
    @eproduct = ::Eproduct.find(params[:id]) 
    respond_to do |format|
      if @eproduct.update_attributes(params[:eproduct])
        flash[:notice] = "#{@eproduct.name} 信息更新成功"
        format.html { redirect_to :action=>:index }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @eproduct.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @eproduct = ::Eproduct.find(params[:id])
    name = @eproduct.name
    @eproduct.destroy
    flash[:notice] = "#{name} 删除成功"
    respond_to do |format|
      format.html { redirect_to :action=>:index }
      format.xml  { head :ok }
    end
  end
  
  
  #数据汇总
  def data
    @eproducts = Eproduct.all(:select=>"eproducts.*,eproduct_tags.*,posts.eproduct_id,posts.content,users.name",:include=>[:eproduct_tag,:post,:user],:order=>"eproducts.id desc")
    render :layout=>false
  end
  
  
end
