class AddUnitAndOrderIdToScoreEvents < ActiveRecord::Migration
  def self.up
    add_column :score_events, :order_id, :integer
    add_column :score_events, :unit, :integer, :default => 1  # 兑换积分数目
    add_column :score_profiles, :exchange_ratio, :integer, :default => 1  # 兑换比例
  end

  def self.down
    remove_column :score_events, :order_id
    remove_column :score_events, :unit
    remove_column :score_profiles, :exchange_ratio
  end
end
