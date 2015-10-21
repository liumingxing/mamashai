class GouVisit < ActiveRecord::Base
  belongs_to :gou
  belongs_to :user
end
