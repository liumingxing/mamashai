class AddAdvToDdh < ActiveRecord::Migration
  def self.up
    add_column :ddhs, :adv, :string

  end

  def self.down
  end
end
