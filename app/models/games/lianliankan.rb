class Games::Lianliankan < ActiveRecord::Base
  set_table_name :games_lianliankans
  
  belongs_to :user
  serialize :info,Hash
  upload_column :logo ,:process => '450x450', :versions => {:thumb48 => "c48x48"}
  
  validates_presence_of :logo,:on=>:create,:message=>'请上传一张游戏背景图片！'
  validates_uniqueness_of :name,:message=>'该游戏名已存在，快给游戏起一个与众不同的名字吧！'
end
