class TuanCategory < ActiveRecord::Base
  has_many :tuans, :dependent => :delete_all
end
