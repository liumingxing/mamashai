class AddCodeToBbrlVersion < ActiveRecord::Migration
  def self.up
    add_column :bbrl_versions, :code, :string
  end

  def self.down
  end
end
