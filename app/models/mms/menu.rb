class Mms::Menu < ActiveRecord::Base
  acts_as_tree
  has_and_belongs_to_many :users, :class_name=>"Mms::User"
end
