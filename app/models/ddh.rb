class Ddh < ActiveRecord::Base
  upload_column :logo , :versions => {:thumb260 => "c260x290",:thumb50 => "c50x60"}

  #before_create :set_status
  before_save :set_status
  validates_presence_of :logo, :message=>"必须要上传logo", :if=> lambda {|i| i.new_record?}
  validates_presence_of :price, :message=>"笨蛋，必须填价格"
  validates_presence_of :score, :message=>"笨蛋，必须写上晒豆数"

  named_scope :duihuan, :conditions=>"(hide is null or hide = 0) and score > 5"

  #设置状态 1:正在进行， 2:还未开始, 3:已经结束
  def set_status
    if self.end_at.to_s < Time.now.to_s(:db)   #已结束
        self.status = 10
    elsif self.begin_at.to_s > Time.now.to_s(:db) #未开始
        self.status = 5
    else                              #正在进行
        if self.remain == 0
          self.status = 6             #兑完了
        else
          self.status = 1             #还有剩余
        end
    end
  end

  def tp
    if self.end_at.to_s < Time.now.to_s(:db)   #已结束
        3
    elsif self.begin_at.to_s > Time.now.to_s(:db) #未开始
        2
    else 
        1
    end 
  end

  def self.json_attrs
    [:id, :score, :price, :title, :content, :count, :remain, :adv, :begin_at, :end_at, :visit, :require_posts_count, :require_level, :require_comments_count]
  end
  
  # 图片地址
  def logo_url
    logo.try(:url)
  end
  
  # 缩略图地址
  def logo_url_thumb260
    logo.try(:thumb260).try(:url)
  end

  def order_count
    DdhOrder.count(:conditions=>"ddh_id=#{self.id}")
  end
  
  def self.json_methods
    %w{logo_url logo_url_thumb260 order_count tp}
  end
  
  def as_json(options = {})

    end_at = self.end_at
    def end_at.to_json(*options)
      self.to_s(:db)
    end
    def end_at.as_json(*options)
      self.to_s(:db)
    end
    begin_at = self.begin_at
    def begin_at.to_json(*options)
      self.to_s(:db)
    end
    def begin_at.as_json(*options)
      self.to_s(:db)
    end

    options[:only] ||= Ddh.json_attrs
    options[:methods] ||= Ddh.json_methods
    super options
  end
end
