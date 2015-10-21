class Mms::NameStickController < Mms::MmsBackEndController
   layout 'mms_admin'
   
  def index
    some_date = Date.today
    search_by_date(some_date)
  end

  def search
    (redirect_to :action=>'index' and return false) if params[:start].blank? and params[:search_key].blank?
    if params[:search_key].blank?
      some_date = Date::civil(params[:start][:year].to_i, params[:start][:month].to_i,params[:start][:day].to_i)
      search_by_date(some_date)
      @search_date = some_date
    else
      @search_key = params[:search_key]
      @name_sticks  = EventNameStick.find(:all,:conditions=> ["users.name like ?",'%'+@search_key+'%'], :include=>[:user],:order=>"event_name_sticks.created_at")
      @count = @name_sticks.count
    end
    render :action=>"index"
  end
  
  def send_messages
    some_date =Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
    flash[:notice] = ""
    @date = some_date
    @name_sticks  = EventNameStick.find(:all,:conditions=> ["created_at between ? and ? and is_sended=?",some_date, some_date+1,0], :order=>:created_at)
    @count = @name_sticks.count
    if @name_sticks.size == 0
      flash[:notice]+=some_date.strftime('%Y年%m月%d日')+"没有中奖用户。"
    else
      @name_sticks.each do |namestick|
          message = {}
          message[:message_post] = {}
          message[:message_post][:user_name] = namestick.user.name
          message[:message_post][:content] = "感谢参与“欢度六一 宝贝姓名贴大放送”活动，妈妈晒提示您：申请的宝贝姓名贴，已按所提供的地址以平邮方式寄出了，注意查收！收到后别忘记到妈妈晒上来Show Show啊，与更多的妈妈爸爸一起分享快乐吧！"
          message_post=MessagePost.create_message_post(message,User.find(431))
          unless message_post.errors.empty?
            flash[:notice]+="向#{namestick.user.email}时发生错误。\n"
          end
          namestick.is_sended = 1
          namestick.save
      end
      flash[:notice]+="发送成功"
    end
    redirect_to :action=>'index'
  end
  
private
  def search_by_date(some_date)
    @date = some_date
    @name_sticks  = EventNameStick.find(:all,:conditions=> ["created_at between ? and ?",some_date, some_date+1], :order=>:created_at)
    @count = @name_sticks.count
  end
end
