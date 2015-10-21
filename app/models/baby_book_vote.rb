class BabyBookVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :baby_book
  
end
