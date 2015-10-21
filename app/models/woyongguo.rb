class Woyongguo < ActiveRecord::Base
  has_many :products, :class_name=>"WoyongguoProduct"
  upload_column :logo ,:process => '800x600', :versions => {:thumb90 => "c90x90"}
end
