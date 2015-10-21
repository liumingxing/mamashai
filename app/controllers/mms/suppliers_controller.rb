class Mms::SuppliersController < Mms::MmsBackEndController
  # GET /mms_suppliers
  # GET /mms_suppliers.xml
  def index
    page = (params[:page] unless params[:page].blank?) || 1
    @suppliers = ::Supplier.paginate :per_page => 22, :page => page, :order => 'created_at DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @suppliers }
    end
  end
  
  def search
    page = (params[:page] unless params[:page].blank?) || 1
    @keyword = (params[:keyword] unless params[:keyword].blank?) || ""
    @suppliers = ::Supplier.paginate :per_page => 22, :page => page, :conditions => ['code LIKE ? or name LIKE ? or contacter LIKE ?', "%#{@keyword}%", "%#{@keyword}%", "%#{@keyword}%"], :order => 'created_at DESC'
    
    render :action => 'index'
  end

  # GET /mms_suppliers/1
  # GET /mms_suppliers/1.xml
  def show
    @supplier = ::Supplier.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @supplier }
    end
  end

  # GET /mms_suppliers/new
  # GET /mms_suppliers/new.xml
  def new
    @supplier = ::Supplier.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @supplier }
    end
  end

  # GET /mms_suppliers/1/edit
  def edit
    @supplier = ::Supplier.find(params[:id])
  end

  # POST /mms_suppliers
  # POST /mms_suppliers.xml
  def create
    @supplier = ::Supplier.new(params[:supplier])

    respond_to do |format|
      if @supplier.save
        format.html { redirect_to(:action=>:show,:id=>@supplier.id, :notice => '::Supplier was successfully created.') }
        format.xml  { render :xml => @supplier, :status => :created, :location => @supplier }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @supplier.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mms_suppliers/1
  # PUT /mms_suppliers/1.xml
  def update
    @supplier = ::Supplier.find(params[:id])

    respond_to do |format|
      if @supplier.update_attributes(params[:supplier])
        format.html { redirect_to(:action=>:show,:id=>@supplier.id, :notice => '::Supplier was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @supplier.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mms_suppliers/1
  # DELETE /mms_suppliers/1.xml
  def destroy
    @supplier = ::Supplier.find(params[:id])
    @supplier.destroy

    respond_to do |format|
      format.html { redirect_to :action=>:index }
      format.xml  { head :ok }
    end
  end
end
