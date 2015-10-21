class AddImagePathToMmsEmail < ActiveRecord::Migration
  def self.up
    add_column :mms_emails, :picture, :string    # 整图路径
    add_column :mms_emails, :images_path, :text     # 切图路径
    add_column :mms_emails, :tuan_id, :integer
    add_column :mms_emails, :url, :string
  end

  def self.down
    remove_column :mms_emails, :picture
    remove_column :mms_emails, :images_path
    remove_column :mms_emails, :url
    remove_column :mms_emails, :tuan_id
  end
end
