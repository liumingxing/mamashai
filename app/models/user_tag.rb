class UserTag < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :user
end
