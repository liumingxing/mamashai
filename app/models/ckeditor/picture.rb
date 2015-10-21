class Ckeditor::Picture < Ckeditor::Asset
  has_attached_file :data,
                    :url  => "/upload/ckeditor_assets/mms/pictures/:id/:style_:basename.:extension",
                    :path => ":rails_root/public/upload/ckeditor_assets/mms/pictures/:id/:style_:basename.:extension",
	                  :styles => { :content => '660>', :thumb => '80x80#' }
	
	validates_attachment_size :data, :less_than=>10.megabytes
	
	def url_content
	  url(:content)
	end
	
	def url_thumb
	  url(:thumb)
	end
	
	def as_json(options = {})
	  options[:methods] ||= []
	  options[:methods] << :url_content
	  options[:methods] << :url_thumb
	  super options
	end
end
