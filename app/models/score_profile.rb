class ScoreProfile < ActiveRecord::Base
  validates_presence_of(:event, :message => "触发时间不能为空")
  validates_uniqueness_of(:event, :message => "触发时间不能重复")
  validates_presence_of(:score, :message => "分值不能为空")
  validates_numericality_of(:score, :message => "分值必须为数字")
  validates_presence_of(:exchange_ratio, :message => "兑换比例不能为空")
  validates_numericality_of(:exchange_ratio, :greater_than => 0, :message => "兑换比例必须大于0")
end
