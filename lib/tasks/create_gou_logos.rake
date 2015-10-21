namespace :mamashai do
  desc "create gou logos  "
  task :create_gou_logos  => [:environment] do
    include MamashaiTools
    def help
      Helper.instance
    end
    
    class Helper
      include Singleton
      include ActionView::Helpers::TextHelper
      include ApplicationHelper
    end
    
    i,count = 0,Gou.count
    puts "开始运行:一共#{count}条数据"
    Gou.find_in_batches do |gous|
      ActiveRecord::Base.transaction do
        gous.each do |gou|
          gou_id = gou.id
          begin
            link = gou[:link] 
          rescue
            puts "gou#{gou_id} link属性读取异常：#{e}"
            next
          end
          
          begin
            gou.logo = get_logo(link) 
          rescue=>e
            puts "gou#{gou_id}获取logo发生异常：#{e}"
            next
          end
          
          begin
            gou.info = MamashaiTools::TextUtil.truncate_long_content(gou.content,210)
          rescue=>e
            puts "gou#{gou_id}生成info发生异常：#{e}"
            next
          end
          
          begin
            gou.save!
          rescue =>e
            puts "gou#{gou_id}保存时发生异常：#{e}"
          end
        end
        i+=1
        puts '已经处理1000x'+i.to_s+"，共#{count}条"
      end
    end
  end
end

def get_logo(link)
  begin 
    logo = RedboyProduct.first(:conditions=>["url=?",link]).logo_file
    file = File.new(File.join(RAILS_ROOT,"public","stuff","images",logo))
  rescue=>e
    puts "从RedboyProduct读取#{link}失败：#{e}"
    return
  end
  return file
end