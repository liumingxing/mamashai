namespace :mamashai do
  desc "清除垃圾文件"
  task :clear_trash  => [:environment] do
    p "begin clean trash"
    `rm -rf /home/web/lama/public/pic_sub/*`
    `rm -rf /home/web/lama/public/pic_trail/*`
    `rm -rf /home/web/lama/public/pic/*`
    `rm -rf /home/web/lama_sina/public/pic_sub/*`
    `rm -rf /home/web/lama_sina/public/pic_trail/*`
    `rm -rf /home/web/lama_sina/public/pic/*`
    `rm -rf /home/web/lama_qq/public/pic_sub/*`
    `rm -rf /home/web/lama_qq/public/pic_trail/*`
    `rm -rf /home/web/lama_sina/public/pic/*`
    `rm -rf /home/web/mamashai0122/public/upload/tmp/*`
    p "clean trash completed"
  end
end