class AjaxEventController < ApplicationController 
  layout nil
  
  before_filter :ajax_need_login_user,:except=>['upload_pictures']
  
  ################# org event ######################
  
  def event_content
    @event = Event.find(params[:id])
    @post = @event.post
  end 
  
  def event_users
    @event = Event.find(params[:id])
    @event_users = @event.event_users
  end
  
  def report_event_users
    @event = Event.find(params[:id])
    @event_users = @event.event_users
  end
  
  def event_posts
    @event_post = Post.find(params[:id])
    @posts = Post.find(:all,:conditions=>['forward_post_id = ?',@event_post.id],:order=>'posts.id desc')
  end
  
  ################### share event ###################
  
  def post_content
    @post = Post.find(params[:id])
  end
  
  def event_summary
    @event = Event.find(params[:id])
  end
  
  def create_event_summary
    @event = Event.find(params[:id])
    @event.summary = params[:event_summary]
    @event.save 
  end
  
  def event_pictures
    @event = Event.find(params[:id])
  end
  
  def event_pictures_upload
    @event = Event.find(params[:id])
  end
  
  def upload_pictures
    @event = Event.find(params[:event_id])
    @user = User.find(params[:uploadid])
    return render_404 unless params[:uploaduid] == MamashaiTools::TextUtil.md5(@user.password)
    EventPicture.create_event_picture(params,@event,@user)
    render :text=>'ok'
  end
  
  def post_videos
    @post = Post.find(params[:id])
  end
  
  def show_event_fees
    @event = Event.find(params[:id])
    @event_fee = @event.event_fee
  end
  
  
  def new_event_cancel
    @event = Event.find(params[:id])
  end
  
  def create_event_cancel
    @event = Event.find(params[:id])
    @event.update_attributes(params[:event])
  end
  
  def update_event_user_remark
    @event_user = EventUser.find(params[:id])
    @event = @event_user.event
    @event_user.update_attributes(:remark=>params[:content])
    render :text=>'{success:1}'
  end
  
  ################### event_users ###################
  
  def new_event_fees
  end
  
  def new_event_user
    @event = Event.find(params[:id])
    @event_user = EventUser.new
    @event_user.mobile = @user.mobile
    @event_user.email = @user.email
  end
  
  def create_event_user
    @event = Event.find(params[:id])
    @event_user = EventUser.create_event_user(params,@event,@user)
    unless @event_user.errors.empty?
      render :text=>"{error:'#{@event_user.errors[:join_num]}'}" and return false
    end
    render :text=>'{success:1}'
  end
  
  def new_event_pay
    @event = Event.find(params[:id])
    @event_pay = EventPay.new 
  end
  
  def create_event_pay
    @event = Event.find(params[:id])
    @event_pay = EventPay.new(params[:event_pay])
    @event_pay.event = @event
    @event_pay.user = @user
    pay_user_ids = params[:pay_user_ids].collect{|m| m[0] if m[1]=='1'}.compact
    @event_pay.pay_user_ids = pay_user_ids.join(',')
    @event_pay.pay_names = User.find(:all,:conditions=>['users.id in (?)',pay_user_ids]).collect{|u| u.name }.join(' ')
    @event_pay.pay_users_count = pay_user_ids.length
    @event_pay.save
    render :text=>'<script>hide_box();</script>'
  end
  
  def confirm_event_pay
    @event_pay = EventPay.find(params[:id])
    @event_pay.status = 'confirm'
    @event_pay.save
    @event = @event_pay.event
    @event_pays = @event.event_pays
    ActiveRecord::Base.transaction do
      EventUser.find(:all,:conditions=>['user_id in (?) and event_id=?',@event_pay.pay_user_ids.split(','),@event.id]).each do |event_user|
        event_user.is_pay = true
        event_user.save
      end
    end
    render :action=>'report_event_pays'
  end
  
  
  def report_event_pays
    @event = Event.find(params[:id])
    @event_pays = @event.event_pays
  end
  
  def report_event_check
    @event = Event.find(params[:id])
    @event_pays = @event.event_pays
  end
  
  def approval_event_user
    @event_user = EventUser.find(params[:id])
    @event = @event_user.event
    @event_user.tp = 1
    @event_user.save
    render :action => 'result_event_user'
  end
  
  def refuse_event_user
    @event_user = EventUser.find(params[:id])
    @event = @event_user.event
    @event_user.tp = -1
    @event_user.save
    @event.event_users_sum -= @event_user.join_num
    @event.save
    render :action => 'result_event_user'
  end
  
  def cancel_event_user
    @event_user = EventUser.find(params[:id])
    @event = @event_user.event
    @event_user.tp = 0
    @event_user.save
    render :action => 'result_event_user'
  end
  
  def new_event_quit
    @event_user = EventUser.find(params[:id])
    @event = @event_user.event
  end
  
  def create_event_quit
    @event_user = EventUser.find(params[:id])
    @event_user.note = params[:event_user][:note]
    @event_user.tp = -2
    @event_user.save 
    @event = @event_user.event
    @event.event_users_sum -= @event_user.join_num
    @event.save
    render :action => 'result_event_user'
  end
  
end
