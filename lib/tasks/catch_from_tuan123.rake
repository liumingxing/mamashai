namespace :mamashai do
  desc "catch tuans from tuan123"
  task :catch_from_tuan123  => [:environment] do
    TuanWebsite.catch_from_tuan123
    puts "catching tuans from tuan123 finished"
  end
end
