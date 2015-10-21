class CreateUserWeixins < ActiveRecord::Migration
  def change
    create_table :user_weixins do |t|
      t.integer :user_id
      t.string  :open_id
      t.string  :access_token
      t.integer :expires_in
      t.string  :refresh_token
      t.string  :scope
      t.timestamps
    end
  end
end
