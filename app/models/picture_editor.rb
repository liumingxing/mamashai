
class PictureEditor < ActiveRecord::Base
  upload_column :logo,:process => '1024x1024',:versions => {:web => "660x900", :thumb120 => "120x120", :thumb400 => "395x395"}
  
  after_create :upload_to_aliyun

	def upload_to_aliyun
	  return if !self.logo
	  return if !File.exist?(self.logo.path)
	    
	  begin                     
	    $connection.put("upload/pictureeditor/#{self.id}/logo/#{self.logo.filename}", File.open(self.logo.path), {:content_type => self.logo.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
	    $connection.put("upload/pictureeditor/#{self.id}/logo/#{self.logo.web.filename}", File.open(self.logo.web.path), {:content_type => self.logo.web.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
	    $connection.put("upload/pictureeditor/#{self.id}/logo/#{self.logo.thumb120.filename}", File.open(self.logo.thumb120.path), {:content_type => self.logo.thumb120.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
	    $connection.put("upload/pictureeditor/#{self.id}/logo/#{self.logo.thumb400.filename}", File.open(self.logo.thumb400.path), {:content_type => self.logo.thumb400.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
	  rescue
	  end
	end
end






