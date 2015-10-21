class DdhController < ApplicationController
  before_filter :get_login_user
  
  layout "main"
  
  def index
    @ddhs = Ddh.duihuan.paginate :page=>params[:page], :per_page=>15, :order=>"status asc, id desc"
    @age_tag = WeekTag.find(:first, :conditions=>"current = 1", :order=>"id desc")
  end
  
  def get
    @ddh = Ddh.find_by_id(params[:id])
    @ddh_order = DdhOrder.find(:first, :conditions=>"user_id = #{@user.id}")
    render :layout=>false
  end
  
  def get_action
    ddh = Ddh.find_by_id(params[:id])
    
    if DdhOrder.find(:first, :conditions=>"user_id = #{@user.id} and ddh_id = #{ddh.id}")
        render :text=>"<script>forwardshine_dialog.content('对不起，您已经申请过了').time(3000)</script>" and return
    end

    if @user.score < ddh.score
      render :text=>"<script>forwardshine_dialog.content('对不起，您的晒豆不足').time(3000)</script>" and return
    end
    
    if ddh.remain > 0
      order = DdhOrder.new(params[:ddh_order])
      order.ddh_id = params[:id]
      order.user_id = @user.id
      order.save
      
      ddh.remain -= 1
      ddh.save
      
      if params[:make_post] == "1"
        post = Post.new
        post.content = params[:content]
        post.user_id = @user.id
        post.logo = ddh.logo
        post.save
      end

      #@user.update_attribute :score, @user.score-ddh.score
      Mms::Score.trigger_event(:make_ddh, "进行豆豆换积分兑换", 1, 1, {:user => @user,:cost=>0-ddh.score,:description=>"兑换：#{ddh.title}"})
      
      render :text=>"<script>forwardshine_dialog.content('您的申请已提交，敬请期待').time(3000)</script>"
    else
      render :text=>"<script>forwardshine_dialog.content('对不起，您来晚了，已经换完了').time(3000)</script>"
    end
  end
  
  def history
    @events = ScoreEvent.find(:all, :conditions=>"user_id = #{@user.id} and score<>0 and created_at > '2012-07-13'", :order=>"id desc", :limit=>10)
    render :layout=>false
  end
end
