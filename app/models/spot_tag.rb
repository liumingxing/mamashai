class SpotTag < ActiveRecord::Base
  has_many :spots
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
