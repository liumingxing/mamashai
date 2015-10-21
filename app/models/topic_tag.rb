class TopicTag < ActiveRecord::Base
  belongs_to :age,  :foreign_key => "obj_id"
  belongs_to :tag
  belongs_to :book, :foreign_key => "obj_id"
end
