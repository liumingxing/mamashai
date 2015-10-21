class AddShortTagNameToAgeTags < ActiveRecord::Migration
  def self.up
    add_column :age_tags, :short_tag_name, :string
  end

  def self.down
    remove_column :age_tags, :short_tag_name
  end
end
