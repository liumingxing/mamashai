namespace :mamashai do
  desc "update gou infos  "
  task :update_gou_infos  => [:environment] do
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
            str = gou.content.gsub(/--------------------------------------------------------------------------------/i,'')
            str = ActionController::Base.helpers.strip_tags(str).gsub(/\r\n/i,'').gsub(/\n\r/i,'').gsub(/\r/i,'').gsub(/\n/i,'').gsub(/\s/i,'')
            str = str.gsub(/发票内容发票内容/i,'发票内容').gsub(/&nbsp;/i,'').gsub(/&radic;/i,'').gsub(/&#13;/i,'').gsub(/&gt;/i,'')
            gou.info = MamashaiTools::TextUtil.truncate(str,300)
            gou.save
          rescue=>e
            puts "gou#{gou_id}生成info发生异常：#{e}"
            next
          end
        end
        i+=1
        puts '已经处理1000x'+i.to_s+"，共#{count}条"
      end
    end
  end
end
