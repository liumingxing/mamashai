class UserQq < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :access_token
end
