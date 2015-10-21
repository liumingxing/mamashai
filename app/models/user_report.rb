class UserReport < ActiveRecord::Base
  belongs_to :user
   
  #validates_length_of :content, :within => 1..1000,:too_long=>'您提交的内容过长',:too_short=>'请填写内容'
 
  
  
end
