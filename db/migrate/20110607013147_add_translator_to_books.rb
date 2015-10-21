class AddTranslatorToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :translator, :string
  end

  def self.down
    remove_column :books, :translator
  end
end
