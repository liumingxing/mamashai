class SysJobLog < ActiveRecord::Base
 
  validates_presence_of :sys_job_name 
  
end
