class Mms::ToolCategoriesController <  Mms::MmsBackEndController
   
  def index
    @categories = Mms::ToolCategory.all
  end
  
  def new
    @category = Mms::ToolCategory.new

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @category }
    end
  end
  
  def create
    @category = Mms::ToolCategory.new(params[:mms_tool_category])
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
    @category = Mms::ToolCategory.find(params[:id])
  end
  
  def update
    @category = Mms::ToolCategory.find(params[:id])
    
    respond_to do |format|
      if @category.update_attributes(params[:mms_tool_category])
        
        flash[:notice] = "#{@category.name} 信息更新成功"
        format.html { redirect_to :action=>:index }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @category = Mms::ToolCategory.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to :action=>:index }
      format.xml  { head :ok }
    end
  end

  
end
