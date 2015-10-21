class AddPostIdToScoreEvents < ActiveRecord::Migration
  def self.up
     add_column :score_events, :post_id, :integer
     add_column :user_profiles, :bind_mobile, :string, :limit=>20
  end

  def self.down
  end
end
