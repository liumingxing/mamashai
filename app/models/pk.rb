class Pk < ActiveRecord::Base
  # attr_accessible :end_date, :max_select, :num, :participate_desc, :photo_desc, :result_date, :reward, :start_date, :title, :calendar_adv_id
  belongs_to :calendar_adv

  def self.latest_end_time
    Rails.cache.fetch("lastest_end_time", :expires_in => 2.hours) do
      arr = self.includes(:calendar_adv).where(calendar_advs: {status: [:online, :test]}).last(5).map{|i| [i.id, i.end_date]}
      arr.inject({}) do |sum, item|
        sum[item.first] = item.last
        sum
      end
    end
  end
end
