class AddDataToFrightProfiles < ActiveRecord::Migration
  def self.up
    FrightProfile.create(:name => "北京地区", :fee => 2.0,:info=>"商品超出一公斤的重量按每公斤2.0元，不足一公斤按一公斤计算。")
    FrightProfile.create(:name => "其他地区", :fee => 7.0,:info=>"商品超出一公斤的重量按每公斤7.0元，不足一公斤按一公斤计算。")
  end

  def self.down
  end
end
