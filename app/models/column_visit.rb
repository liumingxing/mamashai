class ColumnVisit < ActiveRecord::Base
  belongs_to :visitor, :class_name=>"User"
end
