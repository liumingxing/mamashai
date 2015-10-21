class TuanMessage < ActiveRecord::Base
  validates_presence_of :content, :message => "我想团的宝贝不能为空"
  belongs_to :user
end
