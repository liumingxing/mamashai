class FansGroup < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  has_many :follow_users

end
