class CreateWeibotokens < ActiveRecord::Migration
  def self.up
    create_table :weibotokens do |t|
      t.string :platform
      t.string :token
      t.string :secret
      t.string :tp
      t.string :from_str
      t.timestamps
    end
  end

  def self.down
    drop_table :weibotokens
  end
end
