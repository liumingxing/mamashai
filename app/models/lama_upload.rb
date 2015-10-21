class LamaUpload < ActiveRecord::Base
  upload_column :logo, :process => '800x600', :versions => {:thumb200=>"c200x125"}
end
