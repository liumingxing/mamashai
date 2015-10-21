class CalendarAdv < ActiveRecord::Base
	validates_presence_of :logo, :message=>"必须要上传logo"
	
	upload_column :logo, :versions=>{:thumb280=>"c640x280"}

	named_scope :normal,:conditions=>"status = 'online'",:order=>'status desc, position, id desc'

	after_save :upload_to_aliyun

	def upload_to_aliyun
	  return if !self.logo
	  return if !File.exist?(self.logo.path)
	    
	  begin                     
	    $connection.put("upload/calendaradv/#{self.id}/logo/#{self.logo.filename}", File.open(self.logo.path), {:content_type => self.logo.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
	    $connection.put("upload/calendaradv/#{self.id}/logo/#{self.logo.thumb280.filename}", File.open(self.logo.thumb280.path), {:content_type => self.logo.thumb280.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
	  rescue
	  end
	end

	def logo_thumb280
		#logo.try(:thumb280).try(:url)
		logo.url
	end
		
	def self.json_attrs
	    %w{id name tp url code}
	end

	def self.json_methods
	    %w(logo_thumb280)
	end

	def as_json(options = {})
	    options[:only] = (options[:only] || []) + CalendarAdv.json_attrs
	    options[:methods] = (options[:methods] || []) + CalendarAdv.json_methods
	    super options
	end
end
