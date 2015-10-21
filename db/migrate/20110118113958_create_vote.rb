class CreateVote < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
    	t.string :title, :limit=>200, :null=>true
    	t.string :desc, :limit=>200
    	t.integer :user_id
    	t.text :options
    	t.integer :tp
    	t.datetime :endtime
    	t.datetime :created_at
    end
    add_index :votes, :user_id

    create_table :vote_elections do |t|
    	t.integer :vote_id
    	t.integer :user_id
    	t.string :option, :limit=>200
    	t.datetime :created_at
    end
    add_index :vote_elections, :user_id
    add_index :vote_elections, [:vote_id, :user_id]
  end

  def self.down
    drop_table :votes
    drop_table :vote_elections
  end
end
