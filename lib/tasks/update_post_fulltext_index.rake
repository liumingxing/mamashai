namespace :mamashai do
  desc "一次性更新全文检索索引"
  task :update_full_text  => [:environment] do
    log = Logger.new('full.log')
    for post in Post.find(:all)
      content_ = RMMSeg::segment(post.content).join(' ')
      post.update_attribute(:content_, content_)
      log.info "#{post.id} \n"
      #post.make_rmmseg
      #post.save
      #logger.info  "================#{post.id}================"
    end
  end
end