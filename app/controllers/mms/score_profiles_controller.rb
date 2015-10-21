class Mms::ScoreProfilesController < Mms::MmsBackEndController
  def index
    page = params[:page] || 1
    @new_profiles = ::ScoreProfile.all(:conditions=>["description is ? and score = ?",nil,0],:order=>"created_at desc")
    @score_profiles = ::ScoreProfile.paginate(:per_page => 22, :page => page,:order=>"created_at desc")
  end
  
  def new
    @score_profile = ::ScoreProfile.new

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @score_profile }
    end
  end
  
  def create
    @score_profile = ::ScoreProfile.new(params[:score_profile])
    respond_to do |format|
      if @score_profile.save
        flash[:notice] = "#{@score_profile.description} 创建成功"
        format.html { redirect_to :action=>:index }
        format.xml  { render :xml => @score_profile, :status => :created, :location => @score_profile }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @score_profile.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @score_profile = ::ScoreProfile.find(params[:id])
  end
  
  def update
    @score_profile = ::ScoreProfile.find(params[:id])
    
    respond_to do |format|
      if @score_profile.update_attributes(params[:score_profile])
        flash[:notice] = "#{@score_profile.description} 信息更新成功"
        format.html { redirect_to :action=>:index }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @score_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @score_profile = ::ScoreProfile.find(params[:id])
    @score_profile.destroy

    respond_to do |format|
      format.html { redirect_to(:action=>:index) }
      format.xml  { head :ok }
    end
  end
  
end
