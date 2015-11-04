class Mms::PksController < Mms::MmsBackEndController
  # GET /pks
  # GET /pks.json
  before_filter :set_calendar_adv


  # GET /pks/new
  # GET /pks/new.json
  def new
    @pk = Pk.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pk }
    end
  end

  # GET /pks/1/edit
  def edit
    @pk = Pk.find(params[:id])
  end

  # POST /pks
  # POST /pks.json
  def create
    @pk = @calendar_adv.build_pk(params[:pk])

    respond_to do |format|
      if @pk.save
        text = get_dynamic_js
        @pk.calendar_adv.update_column(:url, text)
        format.html { redirect_to edit_mms_calendar_adv_path(@calendar_adv), notice: 'Pk was successfully created.' }
        format.json { render json: @pk, status: :created, location: @pk }
      else
        format.html { render action: "new" }
        format.json { render json: @pk.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pks/1
  # PUT /pks/1.json
  def update
    @pk = Pk.find(params[:id])

    respond_to do |format|
      if @pk.update_attributes(params[:pk])
        text = get_dynamic_js
        @pk.calendar_adv.update_column(:url, text)
        format.html { redirect_to edit_mms_calendar_adv_path(@calendar_adv), notice: 'Pk was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pk.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pks/1
  # DELETE /pks/1.json
  def destroy
    @pk = Pk.find(params[:id])
    @pk.destroy

    respond_to do |format|
      format.html { redirect_to pks_url }
      format.json { head :no_content }
    end
  end

  private

  def set_calendar_adv
    @calendar_adv = CalendarAdv.find(params[:calendar_adv_id])
  end

  def get_dynamic_js
    @pks = Pk.where('id < ?', @pk.id)
    absolute_path = File.join(Rails.root, '/app/mobile_js', 'pk.js.erb')
    if File.exists?(absolute_path)
      render_to_string absolute_path
      # text = ERB.new(File.read(absolute_path)).result(binding)
    else
      nil
    end
  end
end
