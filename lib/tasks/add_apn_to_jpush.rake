require 'rest-client'
require 'base64'

namespace :mamashai do
  desc "将apn发布到jpush上去."
  task :upload_apn  => [:environment] do
    offset = 0
    keys = {1=>"180c3190895aada893a62c6d:c226617a97fe9b7b7d1b4ab0", 2=>"5bf227b6421c1fdff93100e7:b995102310ac3d0f55983ff8", 3=>"dad71d1add1d453eab16f467:dad71d1add1d453eab16f467"}
    apns = ApnDevice.all(:limit=>1000, :offset=>offset, :conditions=>"active = 1 and tp < 4")
    for apn in apns
      headers = {
          "Authorization" => "Basic #{Base64.encode64(keys[apn.tp])}",
      }

      p headers

      url = "https://device.jpush.cn/v3/devices/#{apn.device_token}"
      p RestClient.post(url, headers)
      p apn.id
    end
  end
end
