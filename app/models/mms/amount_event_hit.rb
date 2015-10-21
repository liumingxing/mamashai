class Mms::AmountEventHit < ActiveRecord::Base
  self.table_name = "mms_amount_event_hits"
  has_many :mms_amount_event_refers, :class_name => "Mms::AmountEventRefer", :foreign_key => "mms_amount_event_hit_id", :dependent => :destroy
end
