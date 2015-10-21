class TaoController < ApplicationController
  layout "main"
  
  before_filter :get_login_user

  before_filter :to_main

  def to_main
    redirect_to :controller=>"index"
  end
  
  def index
    @posts = Post.taotaole.paginate(:page=>params[:page], :per_page=>20, :order=>"id desc", :total_entries=>1000)
  end
  
  def baby
    params[:id] ||= '11'
    if !params[:age] && @user && @user.first_kid && @user.age_id > 2
      params[:age] = @user.age_id
    end
    params[:age] ||= '3'
    #    logger.info "===========#{params[:age]}==="
    @ages = Age.find(:all, :conditions=>"id > 2")
    
    @category = TaoCategory.find_by_id(params[:id]) if params[:id]

    redirect_to :action=>"baby" and return if !@category
    
    if @category
      @products = TaoProduct.normal.paginate(:page=>params[:page], :per_page=>40, :conditions=>"category_id in (#{@category.category_ids_with_age(params[:age]).join(',')})", :order=>"position desc, iid")
    else
      @products = TaoProduct.normal.paginate(:page=>params[:page], :per_page=>40, :order=>"position desc, iid")
    end
  end
  
  def yun
    params[:id] ||= 1311
    @root = TaoCategory.find(19)
    @category = TaoCategory.find_by_id(params[:id]) if params[:id]

    redirect_to :action=>"yun" and return if !@category

    if @category
      @products = TaoProduct.normal.paginate(:page=>params[:page], :per_page=>40, :conditions=>"category_id in (#{@category.leaf_ids.join(',')})", :order=>"position desc, iid")
    else
      @products = TaoProduct.normal.paginate(:page=>params[:page], :per_page=>40,  :conditions=>"category_id in (#{@root.leaf_ids.join(',')})", :order=>"position desc, iid")
    end
  end
  
  def show
    @product = TaobaoProduct.find(params[:id])
    baby = [1,2,3,5]
    yun = [357,277,338,314]
    @back = nil
    category = @product.category ? @product.category : TaobaoCategory.find(:first) 
    root = category.get_root
    if baby.include? root.id
      @back = "baby"
    end
    if yun.include? root.id
      @back = "yun"
    end
    if root.id == 4
      @back = "yun"
    end

    @product.update_attribute :click_count, @product.click_count.to_i + 1
    @comments = TaobaoComment.paginate :page=>params[:page], :per_page=>15, :conditions=>"product_id = #{params[:id]}", :order=>"created_at desc"
    @anquan_count = TaobaoComment.count(:conditions=>"product_id = #{params[:id]} and anquan = 1")
    @shiyong_count = TaobaoComment.count(:conditions=>"product_id = #{params[:id]} and shiyong = 1")
    
    @claps = Clap.find(:all, :conditions=>"tp='taobao' and tp_id = #{params[:id]}")
    
    @relative_categories = TaobaoCategory.find(:all, :conditions=>"age = '#{category.age || "2,"}'", :limit=>12)
    @yun_root_children_ids = TaobaoCategory.find(4).category_ids
  end
  
  def share
    redirect_to :controller=>"index", :action=>"index" and return;
    
    @product = TaobaoProduct.find_by_id(params[:id])
    render :layout=>false
  end
  
  def make_share
    product = TaobaoProduct.find(params[:id])
    
    comment = TaobaoComment.new
    comment.user_id = @user.id
    comment.user_name = @user.name
    comment.product_id = params[:id]
    comment.content = params[:content]
    comment.anquan = params[:anquan]
    comment.shiyong = params[:shiyong]
    begin
      comment.save
    rescue
      render :text=>"<script>forwardshine_dialog.content('一个商品只能评论一次哦').time(2000).hideTitle()</script>" and return
    end
    
    post = Post.new
    post.user_id = @user.id
    post.content = params[:content]
    post.from = "wotao"
    post.from_id = params[:id]
    post.logo = open(product.pic_url + "_310x310.jpg") 
    if post.save
      comment.post_id = post.id
      comment.save
    end
    
    if params[:from] == "show"
      render :text=>"<script>forwardshine_dialog.content('提交成功').time(2000).hideTitle()</script>"
    else
      render :text=>"<script>hide_box();</script><li><font>#{@user.name}</font><div class='fr'>#{Time.new.strftime("%y-%m-%d %H:%M")}</div><br/>#{params[:content]}</li>"
    end
  end
  
  def zt
    @zts = Zhuanti.paginate :page=>params[:page], :per_page=>12, :order=>"id desc"
  end

  def the_used
    if params[:id]
      @woyongguo = Woyongguo.find_by_id(params[:id])
    else
      @woyongguo = Woyongguo.find(:first, :order=>"id desc")
    end
    
    @pre_woyongguos = Woyongguo.find(:all, :conditions=>"id < #{@woyongguo.id}", :order=>"id desc")
    @posts = Post.wotao.paginate(:page=>params[:page], :per_page=>15, :order=>"id desc")
    @hot_products = TaobaoProduct.find(:all, :limit=>6)
  end

  private
  def open(url)
    `rm -f /tmp/#{url.split('/').last}`
    `wget -T 10 -P /tmp #{url}`
    begin
      file = File.open("/tmp/" + url.split('/').last, 'rb')
    rescue => err
      p err
      return nil
    end
    return file
  end
end
