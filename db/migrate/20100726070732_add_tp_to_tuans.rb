class AddTpToTuans < ActiveRecord::Migration
  def self.up
    add_column :tuans, :tp, :integer, :default=>0
    add_column :tuans, :back_money, :float, :default=>0.0
    add_column :tuans, :fright_money, :float, :default=>0.0
    add_column :tuans, :free_fright_amount, :integer
    add_column :tuans, :introduction, :text
    add_column :users, :balance, :float, :default=>0.0
  end

  def self.down
    remove_column :users, :balance
    remove_column :tuans, :introduction
    remove_column :tuans, :free_fright_amount
    remove_column :tuans, :fright_money
    remove_column :tuans, :back_money
    remove_column :tuans, :tp
  end
end
