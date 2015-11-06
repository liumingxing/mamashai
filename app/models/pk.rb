class Pk < ActiveRecord::Base
  # attr_accessible :end_date, :max_select, :num, :participate_desc, :photo_desc, :result_date, :reward, :start_date, :title, :calendar_adv_id
  belongs_to :calendar_adv
  validates_uniqueness_of :num

  after_save :create_score_profile

  def create_score_profile
    join_pk = ScoreProfile.find_by_event("join_pk_#{id}")
    join_pk_attrs = {
      event: "join_pk_#{id}",
      description: "参与#{title}活动",
      score: 15,
      exchange_ratio: 1
    }
    if join_pk
      join_pk.update_attributes(join_pk_attrs)
    else
      ScoreProfile.create(join_pk_attrs)
    end

    pk_light = ScoreProfile.find_by_event("pk_light_#{id}")
    pk_light_attrs = {
      event: "pk_light_#{id}",
      description: "晒#{title}活动点灯15次",
      score: 15,
      exchange_ratio: 1
    }
    if pk_light
      pk_light.update_attributes(pk_light_attrs)
    else
      ScoreProfile.create(pk_light_attrs)
    end
  end

  def self.latest_end_time

    block = proc do
      arr = self.includes(:calendar_adv).where(calendar_advs: {status: [:online, :test]}).last(5).map do |i|
        attr = i.attributes.merge(end_date: 86399.seconds.since(i.end_date))
        [i.num, OpenStruct.new(attr)]
      end
      arr.inject({}) do |sum, item|
        sum.merge(item.first => item.last )
      end
    end

    if Rails.env.production?
      Rails.cache.fetch("lastest_end_time", :expires_in => 2.hours, &block)
    else
      block.call
    end
  end
end
