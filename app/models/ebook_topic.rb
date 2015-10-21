class EbookTopic < ActiveRecord::Base
  upload_column :hot_topic_logo, :process => '450x450', :versions => {:thumb90 => "c90x90"}
  upload_column :hot_topic_logo1, :process => '450x450', :versions => {:thumb90 => "c90x90"}
  upload_column :ebook_abstruct_images_1 ,:process => '342x290', :versions=>{:thumb208=>"208x176"}
  upload_column :ebook_abstruct_images_2 ,:process => '342x290', :versions=>{:thumb208=>"208x176"}
  upload_column :ebook_abstruct_images_3 ,:process => '342x290', :versions=>{:thumb208=>"208x176"}
  upload_column :ebook_abstruct_images_4 ,:process => '342x290', :versions=>{:thumb208=>"208x176"}
  
  upload_column :ebook_ipad_free_logo, :versions=>{:thumb66=>"66x80"}
  upload_column :ebook_ipad_pay_logo, :versions=>{:thumb66=>"66x80"}
 # has_many :age, :foreign_key => "id"
  has_many :baidu_app, :foreign_key => "ebook_topic_id"
  
  belongs_to :mfn, :class_name=>"Gou", :foreign_key=>"mfn_id"
end
