class Mms::AppsController < Mms::MmsBackEndController
  # GET /mms_apps
  # GET /mms_apps.xml
  def index
    @mms_apps = Mms::App.all(:order => "default_position")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mms_apps }
    end
  end

  # GET /mms_apps/1
  # GET /mms_apps/1.xml
  def show
    @app = Mms::App.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @app }
    end
  end

  # GET /mms_apps/new
  # GET /mms_apps/new.xml
  def new
    @app = Mms::App.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @app }
    end
  end

  # GET /mms_apps/1/edit
  def edit
    @app = Mms::App.find(params[:id])
  end

  # POST /mms_apps
  # POST /mms_apps.xml
  def create
    @app = Mms::App.new(params[:mms_app])

    respond_to do |format|
      if @app.save
        flash[:notice] = '新建组件成功！'
        format.html { redirect_to(@app) }
        format.xml  { render :xml => @app, :status => :created, :location => @app }
      else
        flash[:notice] = '新建组件失败！'
        format.html { render :action => "new" }
        format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mms_apps/1
  # PUT /mms_apps/1.xml
  def update
    @app = Mms::App.find(params[:id])

    respond_to do |format|
      if @app.update_attributes(params[:mms_app])
        flash[:notice] = '修改组件成功！'
        format.html { redirect_to(@app) }
        format.xml  { head :ok }
      else
        flash[:notice] = '修改组件失败！'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mms_apps/1
  # DELETE /mms_apps/1.xml
  def destroy
    @app = Mms::App.find(params[:id])
    if @app.destroy
      flash[:notice] = "删除组件成功"
      redirect_to :action => :index
    else
      flash[:notice] = "删除组件失败"
      redirect_to :action => :index
    end
  end
  
end
