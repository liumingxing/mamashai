class CalendarTipAdv < ActiveRecord::Base
	validates_presence_of :logo_iphone, :message=>"必须要上传iphne logo"
	validates_presence_of :logo_ipad, :message=>"必须要上传ipd logo"

	upload_column :logo_iphone, :versions=>{:thumb=>"c640x100"}
	upload_column :logo_ipad, :versions=>{:thumb=>"c728x90"}

	def logo_iphone_thumb
		#logo_iphone.try(:thumb).try(:url)
		logo_iphone.url
	end
		
	def logo_ipad_thumb
		#logo_ipad.try(:thumb).try(:url)
		logo_ipad.url
	end
		
	def self.json_attrs
	    %w{id code tp url text}
	end

	def self.json_methods
	    %w(logo_iphone_thumb logo_ipad_thumb)
	end

	def as_json(options = {})
	    options[:only] = (options[:only] || []) + CalendarTipAdv.json_attrs
	    options[:methods] = (options[:methods] || []) + CalendarTipAdv.json_methods
	    super options
	end
end
