class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.string :link_url  #链接地址
      t.string :name     #名称
      t.integer :sort, :default => 0   #排序

      t.timestamps
    end

    names = "爱美网,娃娃会,39育儿,倍儿亲育儿网,幼教网,伊顿国际幼儿园,木蚂蚁安卓市场,人民邮电出版社,新浪微博,起跑线儿歌视频大全,Hers女性网,小学作文网,爱败妈妈网"
    names = names.split(",")
    links = ["http://www.lady8844.com/","http://www.wawahui.com/","http://baby.39.net/","http://www.berqin.com/","http://www.youjiao.com/",
      "http://www.etonkids.com/","http://www.mumayi.com/","http://www.ptpress.com.cn/","http://www.weibo.com/","http://www.qipaoxian.com/",
      "http://www.qipaoxian.com/","http://www.zuowen.com/xiaoxue/","http://www.aibaimm.com/"]
    names.each do |name|
      index = names.index(name)
      Link.create :link_url => links[index], :name => name, :sort => index + 1
    end
  end

  def self.down
    drop_table :links
  end
end
