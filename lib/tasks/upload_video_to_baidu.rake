namespace :mamashai do
  desc "上传视频到百度"
  task :upload_video_to_baidu => [:environment] do
    while 1
      videos = Video.all(:conditions=>"path like '%.mov'")
      for video in videos
        p video.id
        path = video.path.path
        if path.split(".").last.downcase == "mov"     #对mov文件进行转码
          `ffmpeg -i #{video.path.path} -qscale 8 -strict experimental #{File.dirname(path)}/#{video.id}.mp4`
          video.path = File.open("#{File.dirname(path)}/#{video.id}.mp4")
          video.save
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
