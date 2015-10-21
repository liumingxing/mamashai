class Picture < ActiveRecord::Base
  belongs_to :user
  belongs_to :album, :counter_cache => true
  
  validates_presence_of :album_id,:message=>'请选择一个相册' 
  validates_presence_of :logo,:on=>:create,:message=>'请选择上传文件'
  
  upload_column :logo,:process => '1024x1024',:versions => {:web => "600x600",:thumb=>"140x140"}
  
end
