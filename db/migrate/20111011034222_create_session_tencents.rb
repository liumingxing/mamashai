class CreateSessionTencents < ActiveRecord::Migration
  def self.up
    create_table :session_tencent do |t|
      t.integer :rand
      t.string :token
      t.string :secret
      t.timestamps
    end
    
    add_index :session_tencent, :rand
  end

  def self.down
    drop_table :session_tencent
  end
end
