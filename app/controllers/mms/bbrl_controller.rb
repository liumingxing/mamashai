class Mms::BbrlController < Mms::MmsBackEndController
 
  def index 
    @bbrl_users = BbrlUser.paginate(:page=>params[:page],:per_page=>20,:order=>"id desc")
  end
  
end
