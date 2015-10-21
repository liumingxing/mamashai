class WoyongguoProduct < ActiveRecord::Base
  belongs_to :woyongguo
  belongs_to :product, :class_name=>"TaobaoProduct", :foreign_key=>"taobao_product_id"
end
