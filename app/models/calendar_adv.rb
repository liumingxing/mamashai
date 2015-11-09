class CalendarAdv < ActiveRecord::Base
	validate :logo_presence
	validate :end_date_validate
	
	upload_column :logo, :versions=>{:thumb280=>"c640x280"}

	named_scope :normal,:conditions=>"status = 'online'",:order=>'status desc, position, id desc'
	has_one :pk
	after_save :upload_to_aliyun
	default_value_for :manually, true

	def self.synchronize_status
		where(manually: false).where('status <> ?', 'test').each do |adv|
			if (Time.now > adv.start_date) && (Time.now < adv.end_date)
				adv.status = 'online'
				adv.save if adv.changed?
			end

			if 86399.seconds.since(adv.end_date) <= Time.now
				adv.status = 'offline'
				adv.save if adv.changed?
			end
		end
	end

	def upload_to_aliyun
		return unless Rails.env.production?
	  return if !self.logo
	  return if !File.exist?(self.logo.path)
	    
	  begin                     
	    $connection.put("upload/calendaradv/#{self.id}/logo/#{self.logo.filename}", File.open(self.logo.path), {:content_type => self.logo.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
	    $connection.put("upload/calendaradv/#{self.id}/logo/#{self.logo.thumb280.filename}", File.open(self.logo.thumb280.path), {:content_type => self.logo.thumb280.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
	  rescue
	  end
	end

	def end_date_validate
		return if manually?
		errors.add(:end_date, '结束日期必须大于开始日期') unless end_date && start_date && (end_date > start_date)
	end

	def logo_presence
		errors.add(:logo, "必须要上传logo") unless logo?
	end

	def logo_thumb280
		#logo.try(:thumb280).try(:url)
		logo.url
	end

	def logo_ali_url
		"http://img.mamashai.com/upload/calendaradv/#{self.id}/logo/#{self.logo.filename}"
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
