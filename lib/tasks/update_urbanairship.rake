require 'uri'

namespace :mamashai do
  desc "更新urbanairship"
  task :update_urbanairship  => [:environment] do
  	keys = %w(JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ HeMgqDP4SHKrZAn_dS_p1A:GROO_u1AQPi-XLRh9O7ixg 7vYTvD1ISfavgtt-MeQJwg:nWfmYnDhRcKNnNagbMs7tQ)
  	
  	use_offset = true
  	now = Time.new
  	use_offset = false if now.sunday? && now.hour == 6 

  	keys.each_with_index{|key, index|
  		p index + 1
  		json_str = ''
  		if use_offset
  			last_page = ApnLastPage.find_by_tp(index + 1)
  			json_str = `curl -X GET -u "#{key}" -H "Content-Type: application/json" '#{last_page.page_url}'`
  		else
  			json_str = `curl -X GET -u "#{key}" -H "Content-Type: application/json" 'https://go.urbanairship.com/api/device_tokens/?limit=1000'`
	  	end

	  	json = ActiveSupport::JSON.decode(json_str)
	  	while json && json.size > 0 && json['device_tokens']
	  		for device in json['device_tokens']
		  		p device
		  		apn = ApnDevice.find_by_device_token_and_tp(device['device_token'], index + 1)
		  		apn = ApnDevice.new if !apn
		  		apn.user_id = device['tags'][0]
		  		apn.device_token = device['device_token']
		  		apn.active = device['active']
		  		apn.alias = device['alias']
		  		apn.tp = index + 1
		  		apn.save
		  	end
		  	if json['next_page'] 
		  		last_page = ApnLastPage.find_or_create_by_tp(index + 1)
	  			last_page.page_url = json['next_page']
	  			last_page.save if use_offset

		  		json_str = `curl -X GET -u "#{key}" -H "Content-Type: application/json" '#{json['next_page']}'`
	  			json = ActiveSupport::JSON.decode(json_str)
		  	else
		  		json = nil
		  	end
	  	end
  	}

  	keys = %w(JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ HeMgqDP4SHKrZAn_dS_p1A:GROO_u1AQPi-XLRh9O7ixg 7vYTvD1ISfavgtt-MeQJwg:nWfmYnDhRcKNnNagbMs7tQ)
  	keys.each_with_index{|key, index|
  		p index + 4
  		json_str = ""
  		if use_offset && ApnLastPage.find_by_tp(index + 4)
  			last_page = ApnLastPage.find_by_tp(index + 4)
  			json_str = `curl -X GET -u "#{key}" -H "Content-Type: application/json"  '#{last_page.page_url}'`
  		else
	  		json_str = `curl -X GET -u "#{key}" -H "Content-Type: application/json" 'https://go.urbanairship.com/api/apids/?limit=1000'`
		end
		json = ActiveSupport::JSON.decode(json_str)
	  	while json && json.size > 0 && json['apids']
		  		for device in json['apids']
			  		
			  		apn = ApnDevice.find_by_device_token_and_tp(device['apid'], index + 4)
			  		apn = ApnDevice.new if !apn
			  		
			  		apn.user_id = device['tags'][0]
			  		apn.device_token = device['apid']
			  		apn.active = device['active']
			  		apn.alias = URI.decode(device['alias'].to_s)
			  		apn.tp = index + 4
			  		apn.created_at = device['created']
			  		apn.save
			  	end
			  	if json['next_page'] 
			  		last_page = ApnLastPage.find_or_create_by_tp(index + 4)
		  			last_page.page_url = json['next_page']
		  			last_page.save if use_offset

			  		json_str = `curl -X GET -u "#{key}" -H "Content-Type: application/json" '#{json['next_page'].gsub('http:', 'https:')}'`
		  			json = ActiveSupport::JSON.decode(json_str)
			  	else
			  		json = nil
			  	end
		end
	}
  end
end