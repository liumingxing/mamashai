class Mms::EventsController < Mms::MmsBackEndController
  def index
    
    @events = Mms::Event.find(:all,:order=>"id desc")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mms_events }
    end
  end

  def show
    @event = Mms::Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def new
    @event = Mms::Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def edit
    @event = Mms::Event.find(params[:id])
  end

  def create
    @event = Mms::Event.new(params[:mms_event])
    begin_time = params[:mms_event][:begin_time].split('-')
    end_time = params[:mms_event][:end_time].split('-')
    @event.begin_time = Date.new(begin_time[0].to_i,begin_time[1].to_i,begin_time[2].to_i)
    @event.end_time = Date.new(end_time[0].to_i,end_time[1].to_i,end_time[2].to_i)
    respond_to do |format|
      if @event.save
        flash[:notice] = "#{@event.name} 创建成功"
        format.html { redirect_to :action=>:index }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @event = Mms::Event.find(params[:id])
    
    respond_to do |format|
      if @event.update_attributes(params[:mms_event])
        flash[:notice] = "#{@event.name} 信息更新成功"
        format.html { redirect_to :action=>:index }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @event = Mms::Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(mms_events_url) }
      format.xml  { head :ok }
    end
  end
end
