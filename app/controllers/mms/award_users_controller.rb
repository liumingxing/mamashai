class Mms::AwardUsersController < Mms::MmsBackEndController
  def index
    if params[:id]
      @event = Mms::Event.find(params[:id]) 
    else
      @event = Mms::Event.last(:conditions=>["end_time >= ? ",Date.today],:order=>"begin_time desc")
    end
    @award_users = Mms::AwardUser.all(:conditions=>["mms_event_id=?",@event.id],:order=>"award_date desc")
    @current_events = Mms::Event.all(:conditions=>["begin_time <= ? and end_time >= ? ",Date.today,Date.today],:order=>"begin_time desc")
    @old_events = Mms::Event.all(:conditions=>["end_time < ? ",Date.today],:order=>"begin_time desc, created_at desc")
    @old = true unless params[:old].blank?
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mms_award_users }
    end
  end

  def show
    @award_user = Mms::AwardUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @award_user }
    end
  end

  def new
    @award_user = Mms::AwardUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @award_user }
    end
  end

  def edit
    @award_user = Mms::AwardUser.find(params[:id])
  end

  def create
    @award_user = Mms::AwardUser.new(params[:mms_award_user])
    respond_to do |format|
      if @award_user.save
        flash[:notice] = '获奖用户设置成功'
        format.html { redirect_to(:action=>:index, :id=>params[:mms_award_user][:mms_event_id]) }
        format.xml  { render :xml => @award_user, :status => :created, :location => @award_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @award_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @award_user = Mms::AwardUser.find(params[:id])

    respond_to do |format|
      if @award_user.update_attributes(params[:award_user])
        flash[:notice] = 'Mms::AwardUser was successfully updated.'
        format.html { redirect_to(@award_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @award_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @award_user = Mms::AwardUser.find(params[:id])
    @award_user.destroy

    respond_to do |format|
      format.html { redirect_to(mms_award_users_url) }
      format.xml  { head :ok }
    end
  end
  
  def search
    @event = Mms::Event.find(params[:event_id])
    @search_name = params[:search_name] unless params[:search_name].blank?
    @users = ::User.find_all_by_name(@search_name) if @search_name
  end
end
