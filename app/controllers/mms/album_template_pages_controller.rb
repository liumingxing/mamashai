class Mms::AlbumTemplatePagesController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    params[:id] = params[:id] || 4
    @album_template = AlbumTemplate.find_by_id(params[:id])
    @album_template_pages = AlbumTemplatePage.paginate :conditions=>"album_template_id=#{params[:id]}", :page=>params[:page], :per_page => 30, :order=>"position"
  end

  def show
    @album_template_page = AlbumTemplatePage.find(params[:id])
  end

  def new
    @album_template_page = AlbumTemplatePage.new
    @album_template_page.album_template_id = params[:id]
  end

  def create
    @album_template_page = AlbumTemplatePage.new(params[:album_template_page])
    if @album_template_page.save
      flash[:notice] = 'AlbumTemplatePage was successfully created.'
      redirect_to :action => 'list', :id=>@album_template_page.album_template_id
    else
      render :action => 'new'
    end
  end

  def edit
    @album_template_page = AlbumTemplatePage.find(params[:id])
  end

  def update
    @album_template_page = AlbumTemplatePage.find(params[:id])
    if @album_template_page.update_attributes(params[:album_template_page])
      flash[:notice] = 'AlbumTemplatePage was successfully updated.'
      redirect_to :action => 'list', :id=>@album_template_page.album_template_id
    else
      render :action => 'edit'
    end
  end

  def destroy
    AlbumTemplatePage.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def update_logo
    @album_template = AlbumTemplate.find(params[:id])
    @album_template.update_attributes(params[:album_template])
    redirect_to :action=>"list", :id=>params[:id]
  end

  def update_position
    params.each{|key, value|
      ps = key.split("_")
      next if ps.length != 2 || ps[0] != 'p'
      page = AlbumTemplatePage.find(ps[1])
      page.position = value
      page.save
    }

    redirect_to :action=>:list, :id=>params[:id]
  end
end
