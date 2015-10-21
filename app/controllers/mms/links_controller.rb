class Mms::LinksController < Mms::MmsBackEndController
  def list_links 
    params[:id] = 1 if params[:id].blank?
    @link_tag = LinkTag.find(params[:id])
    @links = SysLink.paginate(:per_page => 25,:conditions=>['link_tag_id=?',@link_tag.id],:page => params[:page],:order => "order_num asc") 
  end 
  
  def new_link
    @link = SysLink.new
  end
  
  def edit_link
    @link = SysLink.find(params[:id])
  end
  
  def create_link
    @link = SysLink.new(params[:link])
    @link.order_num = SysLink.maximum('order_num') + 1
    @link.save
    if @link.save 
      redirect_to :action => 'list_links'
    else
      render :action => "new_link",:id=>@link.link_tag_id
    end
  end
  
  def update_link
    @link = SysLink.find(params[:id])
    if @link.update_attributes(params[:link])
      redirect_to :action => 'list_links'
    else
      render :action => "edit_link",:id=>@link.link_tag_id
    end
  end
  
  def set_link_order_up
    @link = SysLink.find(params[:id])
    order_num = @link.order_num
    @link_up = SysLink.find(:first,:conditions=>['order_num < ? and link_tag_id=?',order_num,@link.link_tag_id],:order=>'order_num desc')
    if @link_up
      @link.update_attributes(:order_num=>@link_up.order_num)
      @link_up.update_attributes(:order_num=>order_num)
    end
    redirect_to :action => 'list_links',:id=>@link.link_tag_id
  end
  
  def set_link_order_down
    @link = SysLink.find(params[:id])
    order_num = @link.order_num
    @link_down = SysLink.find(:first,:conditions=>['order_num > ? and link_tag_id=?',order_num,@link.link_tag_id],:order=>'order_num asc')
    if @link_down
      @link.update_attributes(:order_num=>@link_down.order_num)
      @link_down.update_attributes(:order_num=>order_num)
    end
    redirect_to :action => 'list_links',:id=>@link.link_tag_id
  end
  
  def delete_link
    @link = SysLink.find(params[:id])
    link_tag_id = @link.link_tag_id
    @link.destroy
    redirect_to :action => 'list_links',:id=>link_tag_id
  end
end
