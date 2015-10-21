class Bainian < ActiveRecord::Base
  upload_column :logo ,:process => '400x280', :versions => {:thumb140 => "c140x140"}
end
