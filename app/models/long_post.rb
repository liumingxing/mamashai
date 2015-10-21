class LongPost < ActiveRecord::Base
  has_one :post
  validates_length_of :content, :within => 1..10000,:too_long=>APP_CONFIG['error_post_content_length'],:too_short=>APP_CONFIG['error_post_content_length']
end
