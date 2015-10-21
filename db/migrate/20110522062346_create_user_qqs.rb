class CreateUserQqs < ActiveRecord::Migration
  def self.up
    create_table :user_qqs do |t|
      t.integer :user_id
      t.string :openid
      t.string :access_token
      t.string :access_secret
      t.integer :tp  
      
      t.timestamps
    end
    add_index :user_qqs, :user_id
    add_index :user_qqs, :openid
  end

  def self.down
    drop_table :user_qqs
  end
end