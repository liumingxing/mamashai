namespace :mamashai do
  desc "把小秘书的信息转换到资讯中"
  task :transfer_xms  => [:environment] do
    for user in User.find(:all, :conditions=>"name like '%小秘书'")
      for post in user.posts
        if post.long_post
#          article = Article.new
#          article.title = post.title
#          article.state = '已发布'
#          article.article_category_id = 16
#          article.save
#          
#          content = ArticleContent.new
#          content.article_id = article.id
#          content.content = post.long_post.content
#          content.save
          article = Article.find(:first, :conditions=>"article_category_id = 16 and title = '#{post.title}'")
          article.tags = post.age.name if post.age
          article.save if post.age
        end
      end
    end
  end
end
