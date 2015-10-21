class CreateTopicTags < ActiveRecord::Migration
  def self.up
    create_table :topic_tags do |t|
      t.string :topic_tag_type_id
      t.integer :tag_id
      t.string :tag_name

      t.timestamps
    end
    add_index :topic_tags, :tag_id
    add_index :topic_tags, :topic_tag_type_id
  end

  def self.down
    drop_table :topic_tags
  end
end
