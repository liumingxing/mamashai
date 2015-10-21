class CalEnd::Base < ActiveRecord::Base
   self.abstract_class = true   
   establish_connection :cal_end
end
