class Mms::WoyongguosController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    @woyongguos = Woyongguo.paginate :page=>params[:page], :per_page => 10, :order=>"id desc"
  end

  def show
    @woyongguo = Woyongguo.find(params[:id])
  end

  def new
    @woyongguo = Woyongguo.new
  end

  def create
    @woyongguo = Woyongguo.new(params[:woyongguo])
    if @woyongguo.save
      flash[:notice] = '添加我用过活动成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @woyongguo = Woyongguo.find(params[:id])
  end

  def update
    @woyongguo = Woyongguo.find(params[:id])
    if @woyongguo.update_attributes(params[:woyongguo])
      flash[:notice] = '修改我用过活动成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Woyongguo.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  #选择商品
  def select_product
    @woyongguo = Woyongguo.find(params[:id])
    @products = WoyongguoProduct.find(:all, :conditions=>"woyongguo_id = '#{params[:id]}'")
    
    if params[:keyword]
      @results = TaobaoProduct.paginate(:page=>params[:page], :per_page=>16, :conditions=>"name like '%#{params[:keyword]}%'")
    end
  end
  
  def add_to_woyongguo
    @woyonguo = Woyongguo.find(params[:id])
    WoyongguoProduct.create(:woyongguo_id => params[:id], :taobao_product_id=>params[:product_id])
    render :text=>"<script>alert('添加成功')</script>"
  end
  
  def remove_product
    WoyongguoProduct.delete_all("id=#{params[:id]}")
    render :text=>"<script>$('#p_#{params[:id]}').hide(); "
  end
end
