class BokergenVote < ActiveRecord::Base
  attr_accessible :name, :remark, :status, :vote_num, :user_id
  default_value_for :status, "stash"
  validates_uniqueness_of :name
  belongs_to :user
end
