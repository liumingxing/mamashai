class Advertisement < ActiveRecord::Base
  def self.get(code, length=1)
    adv_pos = Advertisement.find_by_code(code)
    logos = AdvertisementLogo.find(:all, :conditions=>"advertisement_id = #{adv_pos.id}", :limit=>length, :order=>"id desc")
  end
end
