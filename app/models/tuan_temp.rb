class TuanTemp < ActiveRecord::Base
  belongs_to :tuan_website, :counter_cache => true
  
  before_save :set_discount,:set_save_money, :if=>Proc.new{|t| t.origin_price and t.current_price}
  attr_protected :tid
  
  def change_to_tuan(params)
      configures = TuanWebsite.configures - %w{root logo}
      
      params = configures.inject(params) do |p,config|
        p[config.to_sym]= self.try(config)
        p
      end
      tuan = Tuan.find_or_create_by_tid(params[:tid])
      params[:tuan_website_id] = self.tuan_website_id
      params[:tuan_category_id] = 1
      t = tuan.update_attributes(params)
      logger.info tuan.errors.map{|e| e.join('-')}
      t
  end
  
  private
  
  def set_discount
     self.discount = ((self.current_price/self.origin_price)*100).round/10.0
  end
  
  def set_save_money
    self.save_money = ((self.origin_price - self.current_price)*100).round/100.0
  end
  
end
