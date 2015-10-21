class CreateCommandQueues < ActiveRecord::Migration
  def self.up
    create_table :command_queues do |t|
      t.text :command
      t.string :status, :default=>"wait"
      t.string :result
      t.timestamps
    end
  end

  def self.down
    drop_table :command_queues
  end
end
