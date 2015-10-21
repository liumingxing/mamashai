class Mms::OrdersController < Mms::MmsBackEndController
  before_filter :get_order_states
  
  def index
    #显示最近1周
    if params[:state]
      @current_state = params[:state]
      @orders = BookOrder.find_all_by_state(@current_state,:order => 'updated_at desc')
      @count = @orders.count
      @orders =  @orders.paginate :page => params[:page], :per_page =>30
    else
      @before_day = Date.today-6
      @end_day = Date.today
      @orders = BookOrder.find(:all, :conditions=>["updated_at between ? and ?",@before_day,@end_day+1],:order => 'updated_at desc')
      @count = @orders.count
      @orders = @orders.paginate :page => params[:page], :per_page =>30
    end    
  end
  
  def show
    @order = BookOrder.find(params[:id])
    @current_state = @order.state.to_s
  end
  
  def edit
    @order = BookOrder.find(params[:id]) 
  end
  
  def update
    @order = BookOrder.find(params[:id])
    @current_state = @order.state
    @order.note = params[:order][:note] if params[:order][:note]
    @order.operator = "妈妈晒客服"
    if params[:order]
      @order.fire_events(params[:order][:state].to_sym)
      flash[:notice]="信息修改成功"
    else
      flash[:notice]="信息未发生变化"  
    end
    redirect_to :action=>:show,:state=>@current_state
  end
  
  def search
    
  end
  
  def make_pdf
    book = BabyBook.find(params[:id])
    item = OrderItem.find(:first, :conditions=>"item_id = #{book.id} and item_type = 'BabyBook'", :order=>"id desc")
    if !item
      file_name = book.generate_pdf(nil,File.join(::Rails.root.to_s, 'public', 'books', 'orders'),"#{book.id}")
      render :text=>"请从这里下载-#{file_name}" and return false
    end
    file_name = book.generate_pdf(nil,File.join(::Rails.root.to_s, 'public', 'books', 'orders'),"#{item.order.id}_#{item.id}_#{item.item_id}")
#    file_name = book.generate_pdf(nil,File.join(RAILS_ROOT, 'public', 'books', 'orders'),"#{item.item_id}")
    flash[:notice] = "生成pdf成功"
    redirect_to :action=>"show", :id=>item.order.id
  end
  
private
  def get_order_states
    @states = BookOrder.array_order_states
  end

end