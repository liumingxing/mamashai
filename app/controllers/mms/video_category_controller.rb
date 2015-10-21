class Mms::VideoCategoryController < Mms::MmsBackEndController
  def index
    params[:tp] = params[:tp] || 1
    @videos = VideoCategory.paginate(:page=>params[:page], :per_page=>16, :order=>"position asc")
  end
  
  def new
    @video = VideoCategory.new
  end
  
  def create
    @video = VideoCategory.new(params[:video])
    
    if !@video.save
      render :action=>"new"
    else
      redirect_to :action=>"index"
    end
  end
  
  def edit
    @video = VideoCategory.find(params[:id])
  end

  def update
    @video = VideoCategory.find(params[:id])
    @video.update_attributes(params[:video])
    redirect_to :action=>"index"
  end
  
  def resources
    @category = VideoCategory.find(params[:id])
    @resources = VideoResource.paginate(:order=>"position asc, id desc", :page=>params[:page], :per_page=>20, :conditions=>"video_category_id = #{params[:id]}")
  end

  def new_resource
    @resource = VideoResource.new
  end

  def create_resource
    @resource = VideoResource.new(params[:resource])
    @resource.video_category_id = params[:id]
    
    if !@resource.save
      render :action=>"new_resource"
    else
      redirect_to :action=>"resources", :id=>params[:id]
    end
  end

  def edit_resource
    @resource = VideoResource.find(params[:id])
  end

  def update_resource
    @video = VideoResource.find(params[:id])
    @video.update_attributes(params[:resource])
    redirect_to :action=>"resources", :id=>@video.video_category_id
  end

  def delete_resource
    @video = VideoResource.find(params[:id])
    @video.destroy
    redirect_to :action=>"resources", :id=>@video.video_category_id
  end

end
