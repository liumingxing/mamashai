namespace :mamashai do
  desc "备份数据库及上传图片"
  task :backup  => [:environment] do
    `rm public/mamashai_data/database.sql`
    `mysqldump -uroot -pmamashai --all-databases > public/mamashai_data/database.sql`
    `rm public/mamashai_data/code.tar`
    `tar cf public/mamashai_data/code.tar /home/lmx/svn`
    
    
    `rm public/backup.tar.gz`
    `rm -rf public/mamashai_data/upload/tmp`
    `tar czf ../../backup.tar.gz public/mamashai_data`
  end
end