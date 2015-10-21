class Mms::DdhOrdersController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    order = "id desc"
    order = params[:order] if params[:order]
    conditions = ["1=1"]
    conditions << "ddh_id = #{params[:ddh_id]}" if params[:ddh_id] && params[:ddh_id].size > 0
    conditions << "users.name like '%#{params[:name]}%'" if params[:name] && params[:name].size > 0
    conditions << "users.id = #{params[:user_id]}" if params[:user_id] && params[:user_id].size > 0
    if params[:ddh_id]
      @ddh_orders = DdhOrder.paginate :page=>params[:page], 
                    :per_page => 10, 
                    :conditions=>conditions.join(" and "), 
                    :joins=>"left join users on users.id = ddh_orders.user_id", 
                    :order=>order
    else
      @ddh_orders = DdhOrder.paginate :page=>params[:page], 
                    :per_page => 10, 
                    :conditions=>conditions.join(" and "), 
                    :joins=>"left join users on users.id = ddh_orders.user_id", 
                    :order=>order,
                    :total_entries=>1000
    end
    #@users = ::User.find :all, :conditions => ["id in (?)", @ddh_orders.map(&:user_id)]
    #@users_hash = @users.group_by(&:id)
  end

  def show
    @ddh_order = DdhOrder.find(params[:id])
  end

  def new
    @ddh_order = DdhOrder.new
  end

  def create
    @ddh_order = DdhOrder.new(params[:ddh_order])
    if @ddh_order.save
      flash[:notice] = 'DdhOrder was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @ddh_order = DdhOrder.find(params[:id])
  end

  def update
    @ddh_order = DdhOrder.find(params[:id])
    if @ddh_order.update_attributes(params[:ddh_order])
      flash[:notice] = '修改订单成功'
      redirect_to :action => 'list', :ddh_id=>params[:ddh_id], :order=>params[:order], :page=>params[:page]
    else
      render :action => 'edit'
    end
  end

  def destroy
    DdhOrder.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def notify_fail
    orders = DdhOrder.find(:all, :conditions=>"ddh_id = #{params[:id]} and status = '等待审核'")
    for order in orders
      order.status = '申请未成功'
      order.save
    end
    redirect_to :action=>"list", :ddh_id => params[:id]
  end

  def batch_update
    for id in params[:p]
      ddh_order = DdhOrder.find(id)
      ddh_order.status = params[:status]
      ddh_order.save
    end
    flash[:notice] = "批量修改订单成功"
    redirect_to :action => 'list', :ddh_id=>params[:ddh_id], :order=>params[:order], :page=>params[:page]
  end

  def batch_update_kd
    lines = params[:text].split("\n")
    for line in lines
      line = line.strip
      ls = line.split("\t")
      order = DdhOrder.find_by_id(ls[0])
      if order
        order.kd_sn = ls[1]
        order.save
      end
    end
    flash[:notice] = "批量导入快递单号成功"
    redirect_to :action=>"list"
  end
end
