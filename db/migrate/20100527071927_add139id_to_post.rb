class Add139idToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, '139id', :integer
    add_column :users, 'is_139', :boolean
  end

  def self.down
    remove_column :posts, '139id'
    remove_column :users, 'is_139'
  end
end
