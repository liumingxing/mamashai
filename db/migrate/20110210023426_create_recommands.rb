class CreateRecommands < ActiveRecord::Migration
  def self.up
    create_table :recommands do |t|
    	t.string :t, :limit=>100
    	t.integer :t_id
    	t.string :operator, :limit=>100
    	t.datetime :created_at
    end
  end

  def self.down
    drop_table :recommands
  end
end
