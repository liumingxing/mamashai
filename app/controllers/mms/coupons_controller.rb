class Mms::CouponsController < Mms::MmsBackEndController
  
  def index
    redirect_to :action=>:users
    #    page = params[:page] || 1
    #    @coupons = ::Coupon.paginate :page => page, :per_page => 30, :order=>"created_at DESC"
  end
  
  def coupons_generate
    
  end
  
  def create
    count = params[:count].to_i
    flash[:error] = "生成个数必须大于0" and render :action => :coupons_generate and return if count <= 0
     (1..count).each do
      sid = MamashaiTools::TextUtil.rand_8_num_str
      coupon =  ::Coupon.new(params[:coupon])
      coupon.sid = sid
      coupon.save
    end
    redirect_to :action => "index"
  end
  
  def show 
    @coupon = ::Coupon.find(params[:id])
  end
  
  def users
    page = params[:page] || 1
    cond = []
    cond << ["coupon_categories.tp = ?",1] if params[:tp]=="tuan"
    cond << ["coupon_categories.tp = ?",2] if params[:tp]=="book"
    @coupons = ::Coupon.paginate :page => page, :per_page => 30, :conditions=>::Coupon.merge_conditions(*cond),:include=>[:user,:coupon_category],:order=>"coupons.created_at DESC"
  end
  
  def categories
    @categories = ::CouponCategory.all(:order=>"created_at desc")
  end
  
  def category_show
    @category = ::CouponCategory.find(params[:id])
  end
  
  def category_new
    @category = ::CouponCategory.new
  end
  
  def category_create
    @category = ::CouponCategory.new(params[:coupon_category])
    respond_to do |format|
      if @category.save
        flash[:notice] = "#{@category.name} 创建成功"
        format.html { redirect_to :action=>:categories }
      else
        format.html { render :action => :category_new }
      end
    end
  end
  
  def category_edit
    @category = ::CouponCategory.find(params[:id])
  end
  
  def category_update
    @category = ::CouponCategory.find(params[:id])
    respond_to do |format|
       if @category.update_attributes(params[:coupon_category])
        flash[:notice] = "#{@category.name} 修改成功"
        format.html { redirect_to :action=>:categories }
      else
        format.html { render :action => :category_edit }
      end
    end
  end
  
  def category_destroy
    @category = ::CouponCategory.find(params[:id])
    @category.destroy
    redirect_to :action=>:categories
  end 
  
end
