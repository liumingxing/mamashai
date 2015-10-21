require 'fileutils'
require 'tmpdir'

class TinymceController < ActionController::Base
  
  def upload_pic
    picture_editor = PictureEditor.new(params[:picture_editor])
    picture_editor.user_id = session[:user_id]
    picture_editor.mms_user_id = session[:mms_user_id]
    picture_editor.save  
    render :text => %Q'
    <script>
       window.parent.document.getElementById("src").value="#{picture_editor.logo_web.url}";
       window.parent.ImageDialog.insertAndClose();   
    </script>'
  end 
   
end
