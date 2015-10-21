
class BabyBookLayout < ActiveRecord::Base
  has_many :baby_book_pages
  validates_presence_of :name
  
  named_scope :published,:conditions=>{:is_publish=>1}

end
