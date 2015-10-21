class UserBookPage < ActiveRecord::Base 
  belongs_to :user
  belongs_to :post
  belongs_to :user_book, :counter_cache => true
  
  upload_column :logo,:process => '1024x1024',:versions => {:web => "310x310"}
  
  validates_presence_of :user_book_id
  validates_length_of :content1,:maximum=>230,:allow_blank => true 
  validates_length_of :content2,:maximum=>230,:allow_blank => true 
  validates_length_of :content3,:maximum=>230,:allow_blank => true 
  
end
