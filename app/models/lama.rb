class Lama < ActiveRecord::Base
  set_table_name :lama
  has_many :lamadiaries, :foreign_key => "uid"
 # upload_column :pic_path , :versions => {:thumb100=>"c100x138", :thumb50=>"c50x69"}
end
