require 'mamashai_tools/album_pdf.rb'
class Mms::AlbumOrdersController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    conditions = ["1=1"]
    conditions << "status = '#{params[:status]}'" if params[:status]
    if params[:status] == "已付款"
      @album_orders = AlbumOrder.paginate :page=>params[:page], :per_page => 10, :order=>"pay_at desc, created_at desc", :conditions=>conditions.join(" and ")
    else
      @album_orders = AlbumOrder.paginate :page=>params[:page], :per_page => 10, :order=>"created_at desc", :conditions=>conditions.join(" and ")
    end
  end

  def show
    @album_order = AlbumOrder.find(params[:id])
  end

  def new
    @album_order = AlbumOrder.new
  end

  def create
    @album_order = AlbumOrder.new(params[:album_order])
    if @album_order.save
      flash[:notice] = 'AlbumOrder was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @album_order = AlbumOrder.find(params[:id])
  end

  def update
    @album_order = AlbumOrder.find(params[:id])
    if @album_order.update_attributes(params[:album_order])
      flash[:notice] = 'AlbumOrder was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    AlbumOrder.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def create_pdf
    order = AlbumOrder.find(params[:id])
    MamashaiTools.generate_album_pdf(order.book_id)
    redirect_to :action=>"list"

    #path = "public/upload/album_orders/#{order.book.created_at.to_date.to_s(:db)}/#{order.book.id}.pdf"
    #send_file path
  end

  def create_pdf_from_book
    book = AlbumBook.find(params[:id])
    MamashaiTools.generate_album_pdf(book.id)
    #path = "public/upload/album_orders/#{book.created_at.to_date.to_s(:db)}/#{book.id}.pdf"
    #send_file path
    redirect_to :action=>"book_list"
  end



  def book_list
    @books = AlbumBook.paginate :page=>params[:page], :per_page=>10, :order=>"id desc"
  end

  def recommand
    book = AlbumBook.find(params[:id])
    book.recommand = !book.recommand
    book.save
    redirect_to :action=>"book_list", :page=>params[:page]
  end

  def sucai
    book = AlbumBook.find(params[:id])
    @book_json = JSON.parse(book.content)
  end

  def rotate
    path = ::Rails.root.to_s + "/public" + params[:path].gsub("_thumb400", "")
    image   = Magick::ImageList.new(path)
    image   = image.rotate(params[:degree].to_i)
    image.write(path)


    path = ::Rails.root.to_s + "/public" + params[:path]
    image   = Magick::ImageList.new(path)
    image   = image.rotate(params[:degree].to_i)
    image.write(path)    
    
    redirect_to :action=>:sucai, :id=>params[:id]
  end
end
