class BabyBookPic < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  
  upload_column :logo,:process => '1024x1024', :versions => {:thumb => "120x120", :thumb500 => "500x500" }, :store_dir=>proc{|pic, file| "babybookpic_new/#{pic.created_at.strftime("%Y-%m-%d")}/#{pic.id}/logo" }
   
end
