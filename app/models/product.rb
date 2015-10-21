require 'state_machine'
class Product < ActiveRecord::Base
  validates_presence_of :name,:code
  validates_uniqueness_of :name,:code

  named_scope :ready
  
  state_machine do
    state :delete

    event :destroy do
      transition nil => :delete
    end
    
    event :return do
      transition :delete => nil
    end
    
  end
 
  def can_ordered?(book)
    return book.try(:baby_book_pages).try(:size) == self.cond.to_i
  end
end
