class CreateTagRelation < ActiveRecord::Migration
  def self.up
    create_table :tag_relations do |t|
      t.integer :tag_id
      t.integer :obj_id
      t.string :obj_from

      t.timestamps
    end

    add_index :tag_relations, :tag_id
    add_index :tag_relations, :obj_id
    add_index :tag_relations, :obj_from

  end

  def self.down
    drop_table :tag_relations
  end
end
