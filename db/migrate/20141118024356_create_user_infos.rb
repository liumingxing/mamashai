class CreateUserInfos < ActiveRecord::Migration
  def change
    create_table :user_infos do |t|
      t.integer :user_id
      t.string :ip
      t.datetime :last_login_at
      t.string :mobile
      t.string :sid
      t.integer :today_comments
      t.integer :today_posts
      t.timestamps
    end

    add_index :user_infos, :user_id
  end
end
