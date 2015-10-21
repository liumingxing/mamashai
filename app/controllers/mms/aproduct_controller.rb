class Mms::AproductController < Mms::MmsBackEndController
  def index
    if params[:id].to_s.size > 0
      @products = AProduct.paginate(:page=>params[:page], :per_page=>30, :conditions=>"hide = 0 and id=#{params[:id]}")
    elsif params[:code].to_s.size > 0
      @products = AProduct.paginate(:page=>params[:page], :per_page=>30, :conditions=>"hide = 0 and code='#{params[:code]}'")
    elsif params[:is_hide] == "1"
      @products = AProduct.paginate(:page=>params[:page], :per_page=>30, :conditions=>"hide = 1")
    else
      conditions=["hide=0"]
      conditions << "category_id = #{params[:category_id]}" if params[:category_id]
      @products = AProduct.paginate(:order=>"position desc, id desc", :page=>params[:page], :per_page=>30, :conditions=>conditions.join(" and "))
    end
  end
  
  def new
    @product = AProduct.new
  end
  
  def create
    @product = AProduct.new(params[:product])
    
    if !@product.save
      render :action=>"new"
    else
      redirect_to :action=>"index"
    end
  end
  
  def edit
    @product = AProduct.find(params[:id])
  end

  def update
    @product = AProduct.find(params[:id])
    @product.update_attributes(params[:product])
    @product.upload_to_aliyun
    Rails::cache.delete("product_detail_of_#{params[:id]}")
    redirect_to :action=>"index", :page=>params[:page], :category_id=>@product.category_id
  end
  
  def delete
    AProduct.find(params[:id]).destroy
    redirect_to :action=>"index", :page=>params[:page]
  end

  def top
    product = AProduct.find(params[:id])
    product.position = product.position.to_i > 1000 ? nil : Time.new.to_i
    product.save
    redirect_to :action=>"index", :page=>params[:page], :category_id=>product.category_id
  end

  def add_logo
    logo = ALogo.new
    logo.aproduct_id = params[:id]
    logo.path = params[:product][:logo]
    logo.save

    product = AProduct.find(params[:id])
    redirect_to :action=>"index", :page=>params[:page], :category_id=>product.category_id
  end

  def delete_logos
    product = AProduct.find(params[:id])
    for logo in product.logos
      logo.destroy
    end
    redirect_to :action=>"index", :page=>params[:page], :category_id=>product.category_id
  end

  def baokuan_list
    @baokuans = ABaokuan.all(:order=>"begin_at")
  end

  def baokuan_new
    @baokuan = ABaokuan.new
  end

  def edit_baokuan
    @baokuan = ABaokuan.find(params[:id])
  end

  def update_baokuan
    @baokuan = ABaokuan.find(params[:id])
    @baokuan.update_attributes(params[:baokuan])
    Rails::cache.delete("product_detail_of_#{@baokuan.a_product_id}")
    redirect_to :action=>"baokuan_list", :page=>params[:page]
  end

  def create_baokuan
    @baokuan = ABaokuan.create(params[:baokuan])
    redirect_to :action=>"baokuan_list"
  end

  def delete_baokuan
    @baokuan = ABaokuan.find(params[:id])
    @baokuan.destroy
    redirect_to :action=>"baokuan_list"
  end

  def chaozhi_list
    @chaozhis = AChaozhi.all(:order=>"id desc")
  end

  def chaozhi_new
    @chaozhi = AChaozhi.new
  end

  def chaozhi_edit
    @chaozhi = AChaozhi.find(params[:id])
  end

  def chaozhi_update
    @chaozhi = AChaozhi.find(params[:id])
    @chaozhi.update_attributes(params[:chaozhi])
    redirect_to :action=>"chaozhi_list", :page=>params[:page]
  end

  def chaozhi_create
    @chaozhi = AChaozhi.create(params[:chaozhi])
    redirect_to :action=>"chaozhi_list"
  end

  def chaozhi_delete
    @chaozhi = AChaozhi.find(params[:id])
    @chaozhi.destroy
    redirect_to :action=>"chaozhi_list"
  end

  def add_article
    product = AProduct.find_by_id(params[:id])
    product.articles << Article.find_by_id(params[:article_id])
    redirect_to :action=>"index", :page=>params[:page], :category_id=>product.category_id
  end

  def delete_article
    product = AProduct.find_by_id(params[:id])
    product.articles.delete Article.find_by_id(params[:article_id])
    redirect_to :action=>"index", :page=>params[:page], :category_id=>product.category_id
  end
end
