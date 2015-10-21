class CreateInviteCodes < ActiveRecord::Migration
  def self.up
     create_table :invite_codes, :force => true do |t|
      t.string :email,:limit=>35
      t.string :invite_code,:limit=>10
      t.datetime :created_at
    end
  end

  def self.down
  end
end
