class AddTaoTopicIdToTaoProducts < ActiveRecord::Migration
  def self.up
  	add_column :tao_products, :tao_topic_id, :integer
  end

  def self.down
  end
end
