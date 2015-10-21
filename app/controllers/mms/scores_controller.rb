class Mms::ScoresController < Mms::MmsBackEndController
  
  def index
   
  end
   
  def create_score_event
    errors = []
    user = ::User.first(:conditions => ['email = ? and name = ?', params[:user_email], params[:user_name]])
    errors << "该用户不存在" if user.blank?
    score_profile = ::ScoreProfile.find(params[:score_profile][:score])
    score_event = Mms::Score.trigger_event(score_profile.event.to_sym, score_profile.description, score_profile.score, score_profile.exchange_ratio, {:user => user}) if user and score_profile
    if score_event.blank?
      errors << "添加积分失败"
      flash[:notice] = errors.join("；")
      render :action => :index
    else
      flash[:notice] = "给用户－#{user.name}－增加－#{score_event.event_description}－#{score_event.score}分成功"
      log = "给用户－#{user.name}－增加－#{score_event.event_description}－#{score_event.score}分成功"
      ScoreEventLog.create(:score_event_id => score_event.id, :user_id => score_event.user_id, :log => log, :operator_name => @mms_user.username)
      redirect_to :action => :show, :user_id => user.id
    end
  end
  
  def show
    unless params[:user_id].blank?
      @user = ::User.find(params[:user_id])
      page = (params[:page] unless params[:page].blank?) || 1
      @score_events = ::ScoreEvent.paginate :per_page => 15, :page => page, :conditions => ['user_id = ?', @user.id], :order => 'created_at DESC'
      @score_event_logs = ::ScoreEventLog.paginate :per_page => 15, :page => page, :conditions => ['user_id = ?', @user.id], :order => 'created_at DESC'
    end
  end
  
  def search
    @keyword = params[:keyword]
    @user = ::User.first(:conditions => ['email = ? or name = ?', @keyword, @keyword])
    flash[:notice] = "该用户不存在" if @user.blank?
    page = (params[:page] unless params[:page].blank?) || 1
    @score_events = ::ScoreEvent.paginate :per_page => 15, :page => page, :conditions => ['user_id = ?', @user.id], :order => 'created_at DESC' if @user
    @score_event_logs = ::ScoreEventLog.paginate :per_page => 15, :page => page, :conditions => ['user_id = ?', @user.id], :order => 'created_at DESC' if @user
    render :action => :show
  end
  
  def destroy
    score_event = ::ScoreEvent.find(params[:id])
    score_event_id = score_event.id
    user = score_event.user
    score = score_event.score
    log = "删除用户－#{user.name}－#{score_event.event_description}－#{score_event.score}分成功"
    if score_event.destroy
      flash[:notice] = "删除积分记录成功！"
      user.score -= score
      user.save
      ScoreEventLog.create(:score_event_id => score_event_id, :user_id => user.id, :log => log, :operator_name => @mms_user.username)
    else
      flash[:notice] = "删除积分记录失败！"
    end
    redirect_to :action => :show, :user_id => user.id
  end
  
end
