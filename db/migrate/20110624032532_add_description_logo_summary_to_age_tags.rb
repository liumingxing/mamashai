class AddDescriptionLogoSummaryToAgeTags < ActiveRecord::Migration
  def self.up
    add_column :age_tags, :description, :text
    add_column :age_tags, :summary, :string
    add_column :age_tags, :logo, :string
    add_column :age_tags, :is_index_hot, :boolean, :default => false
  end

  def self.down
    remove_column :age_tags, :description, :summary, :logo, :is_index_hot
  end
end
