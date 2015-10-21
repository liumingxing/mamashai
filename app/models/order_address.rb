class OrderAddress < ActiveRecord::Base
  belongs_to :user
  belongs_to :province
  belongs_to :city

  validates_presence_of :name,:address,:email,:mobile,:post_code,:province_id,:city_id,:user_id, :message=>"不能为空"
end
