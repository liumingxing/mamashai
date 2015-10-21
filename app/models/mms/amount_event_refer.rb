class Mms::AmountEventRefer < ActiveRecord::Base
  self.table_name = "mms_amount_event_refers"
  belongs_to :mms_amount_event_hit, :class_name => "Mms::AmountEventHit"
end
