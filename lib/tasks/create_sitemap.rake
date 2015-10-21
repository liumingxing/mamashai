require 'builder'  

namespace :mamashai do
  desc "create sitemap.xml for seo"
  task :create_sitemap  => [:environment] do
    
    time_begin = Time.new
    file_name = File.join(RAILS_ROOT,"public","sitemap.xml")
    posts = Post.find(:all,:conditions=>['title is not null'],:order=>"created_at desc",:limit=>40000)
    articles = Article.all(:order=>"created_at desc")
    subjects = Subject.find(:all,:order=>"updated_at desc",:limit=>5000)
    
    File.open(file_name,"w") do |file|
        get_builder(subjects,posts,articles,file)
    end
    puts 'sitemap.xml has been created, costs '+(Time.new-time_begin).to_s+" seconds, the size of sitemap.xml is "+File.size(file_name).to_s+' bytes'
    puts 'sitemap.xml is gzipping, please waiting..........'
    `gzip -c #{file_name} > #{file_name+'.gz'}`
    puts 'sitemap.xml.gz has been created, the size is '+ File.size(file_name+'.gz').to_s+' bytes'
  end
end


def get_builder(subjects,posts,articles,file)
  xml =Builder::XmlMarkup.new(:target => file)
  xml.instruct! :xml, :version=>"1.0" ,:encoding=>"UTF-8"
    xml.urlset :xmlns=> 'http://www.sitemaps.org/schemas/sitemap/0.9' do
      articles.each do |article| 
        xml.url do 
          xml.loc         File.join("http://www.mamashai.com",'article',article.id.to_s)
          xml.lastmod     article.updated_at.strftime('%Y-%m-%d')
          xml.priority    0.9           
          xml.changefreq  "always"         
        end 
      end
      subjects.each do |subject| 
        xml.url do 
          xml.loc         File.join("http://www.mamashai.com",'g',subject.id.to_s)
          xml.lastmod     Time.now.strftime('%Y-%m-%d')
          xml.priority    0.8           
          xml.changefreq  "always"         
        end 
      end
      posts.each do |post| 
        xml.url do 
          xml.loc         File.join('http://www.mamashai.com','post',post.id.to_s)
          xml.lastmod     post.created_at.strftime('%Y-%m-%d')
          xml.priority    0.7           
          xml.changefreq  "hourly"         
        end 
      end 
  end
end
