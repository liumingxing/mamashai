namespace :mamashai do
  desc "transform long posts"
  task :transform_long_posts => [:environment] do
    LongPost.find_each do |post|
      ActiveRecord::Base.transaction do 
        content = ActionController::Base.helpers.simple_format(post.content).gsub(/@(\w{1,20})$|@(\w{1,20})([\s\,\:\：。\，\！\!\(\)\（\）\=\-\[\]"\'\>\<\?\*\/])|@(\w{1,20})@/i,'<a href="/friends/find_user/\\1\\2">@\\1\\2</a>\\3')
        post.update_attributes(:content => content)
      end
    end
    puts "transform long posts finished"
  end
end
