class BlogCategory < ActiveRecord::Base
  belongs_to :user
  has_many :posts
  validates_presence_of(:name, :message => "分类名称不能为空")
  validates_presence_of(:user_id, :message => "用户不能为空")
end
