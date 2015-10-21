namespace :mamashai do
  desc "压缩记录图片."
  task :compress_image  => [:environment] do
  	offset = 0
    posts = Post.all(:conditions=>"id < 203073057 and logo is not null", :order=>"id desc", :limit=>1000, :offset => offset)
    while posts.size > 0
    	for post in posts
    		p post.id
    		p post.logo.path
    		`convert -quality 75% #{post.logo.path} tmp/a.jpeg`
    		`cp tmp/a.jpeg #{post.logo.path}`

    		`convert -quality 75% #{post.logo.thumb400.path} tmp/b.jpeg`
    		`cp tmp/b.jpeg #{post.logo.thumb400.path}`

    		`convert -quality 75% #{post.logo.thumb120.path} tmp/c.jpeg`
    		`cp tmp/c.jpeg #{post.logo.thumb120.path}`
    	end

    	offset += 1000
    	posts = Post.all(:conditions=>"id < 203073057 and logo is not null", :order=>"id desc", :limit=>1000, :offset => offset)
    end
  end
end
