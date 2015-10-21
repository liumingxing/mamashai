class AddObjIdObjFromToTopicTags < ActiveRecord::Migration
  def self.up
    add_column :topic_tags, :obj_id, :integer
    add_column :topic_tags, :obj_from, :string
  end

  def self.down
    remove_column :topic_tags, :obj_from, :obj_id
  end
end
