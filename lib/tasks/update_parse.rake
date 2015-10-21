namespace :mamashai do
  desc "update parse"
  task :update_parse  => [:environment] do
    puts "孕期全程日历"
    

    ApplicationsIDs = %w(nJwnXAVGWQRlDU4nyihzPcrDkSR2XoUil3UfxZsk ghYhOyMFv2huU7UxMuo5mdoAS20VpIyyYBlUNjlc UnLOphymTe6HhVsX1H8qJriGeOfpbzWfEwb4pQhp)
    RESTIDs = %w(psYNG1xYcd0k8IExR4RTlnYd2McjqbCgcaTwwyNK wS69Bvdb5cXy4mrWjiJpuc9k5MWBuCavXJTpdEcT ORr9FxaD3S0wdNgvzY08f2vxMuPZCvf5lXFzE3oW)
    devices = ApnDevice.all(:limit=>20, :conditions=>"tp<=3 and active=1 and parse_obj_id is null and parse_created_at is null", :order=>"id desc")
    while devices.size > 0
      threads = []
      for device in devices
        threads << Thread.new(device) do |device|
          res = `curl --connect-timeout 8 -X POST -H "X-Parse-Application-Id: #{ApplicationsIDs[device.tp - 1]}" -H "X-Parse-REST-API-Key: #{RESTIDs[device.tp - 1]}" -H "Content-Type: application/json" -d '{"deviceType": "ios", "deviceToken": "#{device.device_token}"}' https://api.parse.com/1/installations`
          puts device.id.to_s + ": " + res
          begin
            json = JSON.parse(res)
            if json["error"]
              device.parse_created_at = json["error"]  
              device.save
              next
            else
              device.parse_obj_id = json["objectId"]
              device.parse_created_at = json["createdAt"]||json["updatedAt"]
              device.save
            end
          rescue => err 
            p err
          end
        end
      end
      threads.each{|th| th.join(8)}
      devices = ApnDevice.all(:limit=>20, :conditions=>"tp<=3 and active=1 and parse_obj_id is null and parse_created_at is null", :order=>"id desc")
    end
  end
end