class AddTaoIdsToTaoTopics < ActiveRecord::Migration
  def self.up
  	add_column :tao_topics, :tao_ids, :string
  end

  def self.down
  end
end
