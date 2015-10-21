class Mms::GiftsController < Mms::MmsBackEndController
  def list_gifts 
    @gifts = Gift.paginate(:per_page => 25,:page => params[:page],:order => "id asc") 
  end 
  
  def new_gift
    @gift = Gift.new
  end
  
  def edit_gift
    @gift = Gift.find(params[:id])
  end
  
  def create_gift
    @gift = Gift.new(params[:gift])
    if @gift.save 
      redirect_to :action => 'list_gifts'
    else
      render :action => "new_gift"
    end
  end
  
  def update_gift
    @gift = Gift.find(params[:id])
    if @gift.update_attributes(params[:gift])
      redirect_to :action => 'list_gifts'
    else
      render :action => "edit_gift"
    end
  end
  
  def delete_gift
    @gift = Gift.find(params[:id])
    @gift.destroy
    redirect_to :action => 'list_gifts'
  end
end
