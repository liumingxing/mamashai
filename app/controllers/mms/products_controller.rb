class Mms::ProductsController < Mms::MmsBackEndController
  
  def index
    @state = params[:state]
    @products = Product.find_all_by_state(@state)
  end
  
  def new
    @product = Product.new
  end
  
  def create
    @product = Product.new(params[:product])
    if @product.save
      flash[:notice]="保存成功"
      redirect_to :action=>:index
    else
      flash[:notice]="保存失败，请检查信息是否输入正确。"
      redirect_to :back
    end
    
  end
  
  def edit
    @product = Product.find(params[:id])
    unless @product
      flash[:notice]="无记录"
      redirect_to :action=>:index
    end
  end
  
  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      flash[:notice]="设置成功"
    else
      flash[:notice]="操作失败"
    end
    redirect_to :back
  end
  
  def destroy
    @product = Product.find(params[:id])
    if @product.fire_events(:destroy)
      flash[:notice]=@product.name+"已删除成功"   
   else
    flash[:notice]=@product.name+"删除失败"  
   end
    redirect_to :action=>:index
  end
  
  def return_new
    @product = Product.find(params[:id])
    if @product.fire_events(:return)
      flash[:notice]=@product.name+"已恢复成功"   
    else
      flash[:notice]=@product.name+"恢复失败"  
    end
    redirect_to :action=>:index,:state=>"delete"
  end
  
end
