class AddMmsUserIdAndUserIdAndLogoToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :mms_user_id, :integer
    add_column :books, :user_id, :integer
    add_column :books, :logo, :string
  end

  def self.down
    remove_column :books, :mms_user_id, :user_id, :logo
  end
end
