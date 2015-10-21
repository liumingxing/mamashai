class UserScoreStatisticConfig < ActiveRecord::Base
  has_many :user_score_statistics
  named_scope :all_actives,:conditions=>{:is_active=>true},:order=>"user_score_statistic_configs.created_at desc"
  validates_presence_of :name,:start_date,:end_date
end
