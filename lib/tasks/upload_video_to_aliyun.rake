namespace :mamashai do
  desc "上传视频到百度"
  task :upload_video_to_aliyun => [:environment] do
    while 1
      videos = Video.all(:conditions=>"url is null")
      for video in videos
        begin
          p video.id
          path = video.path.path
          if path.split(".").last.downcase == "mov"     #对mov文件进行转码
            `ffmpeg -i #{video.path.path} -qscale 8 -strict experimental #{File.dirname(path)}/#{video.id}.mp4`
            file = File.open("#{File.dirname(path)}/#{video.id}.mp4")
            video.path = file
            video.save
            file.close
          end

          url = $connection.put(video.path.url.gsub(/^\//, ''), File.open(video.path.path), {:content_type => "audio/mpeg3"})
          video.url = url.gsub("mamashai-videos.oss-cn-qingdao.aliyuncs.com", "img.mamashai.com")
          video.save
        rescue
        end
#        `curl -T #{video.path.path} -v "http://bcs.duapp.com/mamashai-video/#{video.id}.mp4"`
#        video.url = "http://bcs.duapp.com/mamashai-video/#{video.id}.mp4"
#        video.save
      end
      p Time.new
      sleep(5)
    end
  end
end
