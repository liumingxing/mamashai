class CreateSysJobLogs < ActiveRecord::Migration
  def self.up
    create_table :sys_job_logs, :force => true do |t|
      t.string :sys_job_name,:limit=>20
      t.datetime :created_at
      t.datetime :finished_at
    end
  end
  
  def self.down
  end
end
