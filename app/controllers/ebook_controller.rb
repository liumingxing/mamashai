class EbookController < ApplicationController
#  before_filter :get_login_user
#  before_filter :get_follow_user_ids
  before_filter :to_main


  def to_main
    redirect_to :controller=>"index"
  end
end
