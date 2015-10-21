class BookVisit < ActiveRecord::Base
  belongs_to :book
  belongs_to :user
end
