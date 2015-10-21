class CreateNaLogs < ActiveRecord::Migration
  def self.up
    create_table :na_logs do |t|
      t.integer :user_id
      t.integer :gou_id
      t.string :status, :default=>"try"    #get try
      t.timestamps
    end
  end

  def self.down
    drop_table :na_logs
  end
end
