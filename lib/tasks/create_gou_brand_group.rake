namespace :mamashai do
  desc "create gou brand group"
  task :create_gou_brand_group  => [:environment] do
    
    include MamashaiTools
    def help
      Helper.instance
    end
    
    class Helper
      include Singleton
      include ActionView::Helpers::TextHelper
      include ApplicationHelper
    end
    i,count,user = 0,GouBrand.count,User.find(User.mms_user_id)
    puts "开始运行:一共#{count}条数据"
    GouBrand.find_in_batches(:batch_size=>100) do |brands|
      ActiveRecord::Base.transaction do
        brands.each do |brand|
          brand_id = brand.id
          begin
            subject = Subject.find_or_initialize_by_name(brand.name+"粉丝群")
            story = brand.try(:article).try(:article_content).try(:content)
            story = story.blank? ? "这里是#{brand.name}粉丝群" : story
            subject.content =  MamashaiTools::TextUtil.truncate_long_content(story.gsub(/\s/i,'').gsub(/(&nbsp;)|(&ldquo;)|(&rdquo;)/i,'').gsub(/&radic;/i,'').gsub(/&#13;/i,'').gsub(/&gt;/i,''),1500)
            subject.user = user
            subject.logo = brand.logo
            brand.subject = subject
            if subject.save(false)
              su = SubjectUser.new(:user_id=>user.id)
              su.subject = subject
              su.save
              brand.save
            end
            rescue=>e
            puts "gou_brand#{brand_id}生成粉丝群发生异常：#{e}"
            next
          end
        end
        i+=1
        puts '已经处理100x'+i.to_s+"，共#{count}条"
      end
    end
    puts "完成，一共#{count}条数据"
  end
end
