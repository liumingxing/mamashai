class AddStatusToTaoTopic < ActiveRecord::Migration
  def self.up
  	add_column :tao_topics, :status, :string, :default=>"offline"
  end

  def self.down
  end
end
