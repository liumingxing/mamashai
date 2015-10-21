class Api::VideosController < Api::ApplicationController
  def categories
    render :json=>VideoCategory.all(:order=>"position", :conditions=>"parent_video_category is null")
  end

  def videos
    resources = VideoResource.paginate(:page=>params[:page], :per_page=>20, :order=>"position asc, id desc", :conditions=>"logo is not null and video_category_id = #{params[:id]}")
    render :json=>resources 
  end

  def visit
  	video = VideoResource.find(params[:id])
    VideoResource.update_all "visit_count = visit_count + 1", "page_url = '#{video.page_url}'"
  	render :text=>(video.visit_count+1).to_s
  end
  
end