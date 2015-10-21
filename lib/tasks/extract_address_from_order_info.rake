# -*- coding: utf-8 -*-
namespace :mamashai do
  desc "extract address from order info"
  task :extract_address_from_order_info  => [:environment] do
    TuanOrder.all.each do |order|
      order.update_attributes(:receiver_name=>order.info[:receiver_name],:receiver_address=>order.info[:receiver_address],:receiver_mobile=>order.info[:mobile]) if order.info and order.info[:receiver_name]
    end
  end
end