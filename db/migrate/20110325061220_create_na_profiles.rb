class CreateNaProfiles < ActiveRecord::Migration
  def self.up
    create_table :na_profiles do |t|
      t.integer :gou_id
      t.string :email, :limit=>100        #联系人email，有人拿到后自动发信
      t.float :weight, :default=>0
      t.integer :random, :default=>10
      t.integer :total_count              #总数量
      t.integer :has_sent, :default=>0    #已送出
      t.string :site1, :limit=>200
      t.string :site2, :limit=>200
      t.string :site3, :limit=>200
      t.string :question1, :limit=>200
      t.string :option1, :limit=>200
      t.string :answer1, :limit=>100
      t.string :question2, :limit=>200
      t.string :option2, :limit=>200
      t.string :answer2, :limit=>100
      t.string :question3, :limit=>200
      t.string :option3, :limit=>200
      t.string :answer3, :limit=>100
      t.string :ext1, :limit=>200
      t.string :ext2, :limit=>200
      t.string :ext3, :limit=>200
      t.timestamps
    end
  end

  def self.down
    drop_table :na_profiles
  end
end
