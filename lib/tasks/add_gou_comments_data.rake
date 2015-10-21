namespace :mamashai do
  
  desc "update_rid_tuan_comments"
  task :update_rid_tuan_comments  => [:environment] do
    require 'md5'
    TuanComment.find_in_batches(:conditions => ['user_name IS NOT NULL AND site_name IS NOT NULL '], :batch_size => 100) do |comments|
      ActiveRecord::Base.transaction do
        comments.each_with_index do |comment, index|
          rid = MD5.new([comment.content, comment.user_name].join).hexdigest
          comment.update_attribute(:rid, rid)
          puts comment.inspect if index % 100 == 0
        end
      end
    end
  end
  
  desc "add gou comments data"
  task :add_gou_comments_data  => [:environment] do
    TempGouComment.find_in_batches(:batch_size => 100) do |comments|
      ActiveRecord::Base.transaction do
        comments.each_with_index do |comment, index|
          gou = Gou.first(:conditions => ['link = ?', comment.number])
          next if gou.blank?
          tuan_comment = TuanComment.first(:conditions => ['rid = ?', comment.rid])
          tuan_comment.update_attributes(:rate => comment.evaluate_level, :content => comment.content, :created_at => comment.evaluate_time, :user_name => comment.username, :site_name => "红孩子商城", :gou_id => gou.id, :rid => comment.rid) if tuan_comment.present?
          tuan_comment = TuanComment.create(:rate => comment.evaluate_level, :content => comment.content, :created_at => comment.evaluate_time, :user_name => comment.username, :site_name => "红孩子商城", :gou_id => gou.id, :rid => comment.rid) if tuan_comment.blank?
          puts tuan_comment.inspect if index % 100 == 0
        end
      end
    end
  end
end