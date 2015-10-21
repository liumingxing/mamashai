# -*- coding: utf-8 -*-
require 'state_machine'
class Order < ActiveRecord::Base
  
  has_many :order_items
  has_many :order_logs
  belongs_to :coupon
  belongs_to :user
  serialize :info,Hash
  attr_accessor :operator,:note
  attr_protected :state
  
  @@number = 100001
  
  def self.get_order_id(order_sn)
    order_sn.to_i - @@number
  end
  
  def self.get_bank_key
    keys = YAML.load_file(File.join(::Rails.root.to_s,'config','payment.yml'))
    key=keys['chinabank']['md5']
  end
  
  def order_sn
    self.id + @@number
  end
  
  def self.order_sn_view(order_id)
     order_id + @@number
  end
  
  named_scope :sn, lambda{|sn|
    { :conditions => { :id => sn.to_i-@@number } }
  }
  
  def get_payment(payment={})
    begin
      keys = YAML.load_file(File.join(::Rails.root.to_s,'config','payment.yml'))
      key=keys['chinabank']['md5']
    rescue
      logger.error "网银在线密钥读取错误"
      return {}
    end 
    payment[:v_mid] = '21659404'
    payment[:v_oid] = self.order_sn
    payment[:v_amount] = self.total_money
    payment[:v_moneytype] = 'CNY'
    #merge时候注意下方的网址
    payment[:v_url] = 'http://www.mamashai.com/orders/receive'
    payment[:v_md5info] = Digest::MD5.hexdigest("#{payment[:v_amount]}#{payment[:v_moneytype]}#{payment[:v_oid]}#{payment[:v_mid]}#{payment[:v_url]}#{key}").upcase
    
    payment[:remark1] = ""
    payment[:remark2] = ""
    payment
  end
  
end
