class BaiduApp < ActiveRecord::Base
 upload_column :image_url ,:process => '64x64', :versions => {:thumb140 => "c140x140",:thumb30 => "c30x30", :thumb48 => "c48x48", :thumb64 => "c64x64"}
end
