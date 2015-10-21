  class Mms::ToolsController <  Mms::MmsBackEndController
    def index
      page = params[:page] || 1
      @categories = Mms::ToolCategory.all
      @category = Mms::ToolCategory.find(params[:id]) rescue @category=nil
      if @category
        @tools = Mms::Tool.paginate(:per_page => 50, :page => page, :conditions=>["mms_tools.mms_tool_category_id=?",@category.id],:include=>[:mms_tool_category,:tuan],:order=>"mms_tools.created_at desc")
      else
        @tools = Mms::Tool.paginate(:per_page => 50, :page => page, :include=>[:mms_tool_category,:tuan],:order=>"mms_tools.created_at desc")
      end
    end
    
    def new
      @tool = Mms::Tool.new
      
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @tool }
      end
    end
    
    def create
      @tool = Mms::Tool.new(params[:mms_tool])
      respond_to do |format|
        if @tool.save
          flash[:notice] = "#{@tool.name} 创建成功"
          format.html { redirect_to :action=>:index }
          format.xml  { render :xml => @tool, :status => :created, :location => @tool }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @tool.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    def edit
      @tool = Mms::Tool.find(params[:id])
    end
    
    def update
      @tool = Mms::Tool.find(params[:id])
      old_id=@tool.mms_tool_category_id
      respond_to do |format|
        if @tool.update_attributes(params[:mms_tool])
          new_id = @tool.mms_tool_category_id
          unless old_id == new_id
            Mms::ToolCategory.update_counters old_id, :mms_tools_count => -1
            Mms::ToolCategory.update_counters new_id, :mms_tools_count => +1
          end
          flash[:notice] = "#{@tool.name} 信息更新成功"
          format.html { redirect_to :action=>:index }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @tool.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    def destroy
      @tool = Mms::Tool.find(params[:id])
      @tool.destroy
      
      respond_to do |format|
        format.html { redirect_to(mms_tools_url) }
        format.xml  { head :ok }
      end
    end
    
    
  end
