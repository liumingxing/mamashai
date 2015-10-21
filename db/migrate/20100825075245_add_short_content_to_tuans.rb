class AddShortContentToTuans < ActiveRecord::Migration
  def self.up
    add_column :tuans, :short_content, :string
  end

  def self.down
    remove_column :tuans, :short_content
  end
end
